# Module for maximum smoothness forward curve


struct SmoothSpline
	taus::Vector{Tuple{Float64, Float64}}
	knots::Vector{Float64}
	prices::Vector{Float64}
	n::Int
	m::Int
	polynomials::Vector{Polynomial}
	H::Matrix{Float64}
	A::Matrix{Float64}
	B::Vector{Float64}
	X::Matrix{Float64}

	# Inner constructor initializes only a subset of the fields
	function SmoothSpline(tau_begin::Vector{Float64}, tau_end::Vector{Float64}, prices::Vector{Float64})

		# Create a vector of tuples representing the start and end days
		taus = collect(zip(tau_begin, tau_end))

		# Create a sorted vector of unique days from both start_time and end_time
		knots = [0; sort(unique(vcat(tau_begin, tau_end)))]

		n = length(knots) - 1
		m = length(taus)

		# Set up problem
		H = calc_big_H(knots, n)
		A = calc_big_A(taus, knots, m, n)
		B = calc_B(taus, prices, m, n)

		# Solve problem
		X = solve_lineq(n, H, A, B)
		# Set up polynomials from solution X
		polynomials = [Polynomial(reverse(coeffs), :t) for coeffs in eachrow(X)]
		new(taus, knots, prices, n, m, polynomials, H, A, B, X)
	end
end



function price(spline::SmoothSpline, time::Float64)
    for (i, poly) in enumerate(spline.polynomials)
        if spline.knots[i] <= time < spline.knots[i+1]
            return poly(time)
        end
    end
    error("Time $time is outside the range of the spline")
end

# Calculate spline average
function price(spline::SmoothSpline, start_time::Float64, end_time::Float64)
	if start_time > end_time
		error("Start is after end")
	end

	if start_time < spline.knots[1] || end_time > spline.knots[end]
		error("Integration bounds are outside the range of the spline")
	end

	total_integral = 0.0
	total_duration = end_time - start_time
	for (i, poly) in enumerate(spline.polynomials)
		segment_start = max(start_time, spline.knots[i])
		segment_end = min(end_time, spline.knots[i+1])

		if segment_start < segment_end
			segment_integral = integrate(poly, segment_start, segment_end)
			total_integral += segment_integral
		end
	end

	return total_integral / total_duration
end


# Calculate H matrix
function calc_H(tau_b::Float64, tau_e::Float64)
	return [
		(144/5)*(tau_e^5-tau_b^5) 18*(tau_e^4-tau_b^4) 8*(tau_e^3-tau_b^3) 0 0;
		18*(tau_e^4-tau_b^4) 12*(tau_e^3-tau_b^3) 6*(tau_e^2-tau_b^2) 0 0;
		8*(tau_e^3-tau_b^3) 6*(tau_e^2-tau_b^2) 4*(tau_e-tau_b) 0 0;
		0 0 0 0 0;
		0 0 0 0 0
	]
end

# Calculate big H matrix
function calc_big_H(knots, n)
	h_matrices = [calc_H(knots[i], knots[i+1]) for i in 1:n]
	return BlockDiagonal(h_matrices)
end

# Calculate integral constraint
function calc_integral_constraint(tau_b::Float64, tau_e::Float64)
	return [
		(tau_e^5 - tau_b^5) / 5
		(tau_e^4 - tau_b^4) / 4
		(tau_e^3 - tau_b^3) / 3
		(tau_e^2 - tau_b^2) / 2
		tau_e - tau_b
	]
end

# Calculate knot constraints
function calc_knot_constraints(u_j::Float64)
	return [
		u_j^4 u_j^3 u_j^2 u_j 1;
		4*u_j^3 3*u_j^2 2*u_j 1 0;
		12*u_j^2 6*u_j 2 0 0
	]
end

# Calculate B matrix
function calc_B(taus, prices, m, n)
	B = zeros(Float64, 3 * n + m - 2)
	for (i, (tau_b, tau_e)) in enumerate(taus)
		B[3*(n-1)+1+i] = prices[i] * (tau_e - tau_b)
	end
	return B
end

# Solve linear equation
function solve_lineq(n, H, A, B)
	top = hcat(2 * H, transpose(A))
	btm = hcat(A, zeros(size(A, 1), size(transpose(A), 2)))
	A_merged = vcat(top, btm)
	B_merged = vcat(zeros(size(top, 2) - length(B)), B)
	Solution = A_merged \ B_merged
	X = transpose(reshape(Solution[1:n*5], 5, n))
	return Matrix(X)

end

# Calculate big A matrix
function calc_big_A(taus, knots, m, n)
	A = zeros(Float64, 3 * n + m - 2, 5 * n)

	for (i, knot) in enumerate(knots[2:end-1])
		c1 = calc_knot_constraints(knot)
		A[(3*i-2):(3*i), (5*i-4):(5*i)] = c1
		A[(3*i-2):(3*i), (5*i+1):(5*i+5)] = -c1
	end

	# End constraint last knot:first derivative in knot = 0
	A[3*(n-1)+1, end-4:end] = [4 * knots[end]^3, 3 * knots[end]^2, 2 * knots[end], 1, 0]

	# No arbitrage constraints
	for (i, tau) in enumerate(taus)
		tau_b, tau_e = tau
		for (j, knot) in enumerate(knots[2:end])
			prev_knot = knots[j]  # j in enumerate starts from 1, so knots[j] is actually the previous knot
			if tau_e > prev_knot && tau_b < knot
				t1 = max(tau_b, prev_knot)
				t2 = min(knot, tau_e)
				A[3*(n-1)+1+i, (5*j-4):(5*j)] = calc_integral_constraint(t1, t2)
			end
		end
	end

	return A
end

function plot_spline(spline::SmoothSpline, resolution::Int = 1000)
	plt = plot(size = (1200, 800))  # Initialize an empty plot
	for (i, coeffs) in enumerate(eachrow(spline.X))
		p = Polynomial(reverse(coeffs))
		interval_start = spline.knots[i]
		interval_end = spline.knots[i+1]

		# Generate points to plot the polynomial
		xs = range(interval_start, stop = interval_end, length = 100)
		ys = p.(xs)

		# Plot the polynomial over the interval without names
		plot!(xs, ys, label = "")
	end
	return plt
end
