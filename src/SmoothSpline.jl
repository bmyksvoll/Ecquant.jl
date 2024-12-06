# Module for maximum smoothness forward curve
module SmoothSpline

using Dates
using Plots
using LinearAlgebra
using Polynomials
using BlockDiagonals

#= 
struct SmoothSpline
    taus::Vector{Tuple{Int,Int}}
    knots::Vector{Int}
    prices::Vector{Float64}
    n::Int
    m::Int
    polynomial_intervals::Vector{Vector{Int}}
    H::Matrix{Float64}
    A::Matrix{Float64}
    B::Vector{Float64}
    X::Vector{Vector{Float64}}
    # Inner constructor initializes only a subset of the fields
    function SmoothSpline(taus::Vector{Tuple{Int,Int}}, knots::Vector{Int}, prices::Vector{Float64})
        n = length(knots) - 1
        m = length(taus)
        polynomial_intervals = [[start, knots[i+1]] for (i, start) in enumerate(knots[1:end-1])]
        H = calc_big_H(knots, n)
        A = calc_big_A(taus, knots, m, n)
        B = calc_B(taus, prices, m, n)
        X = solve_lineq(H, A, B)
        new(taus, knots, prices, n, m, polynomial_intervals, Matrix{Float64}(undef, 0, 0), Matrix{Float64}(undef, 0, 0), Float64[], Vector{Vector{Float64}}(undef, 0))
    end
end
 =#

# Polynomial function
polynomial_function(t::Int, coef::Vector{Float64}) = polyval(Polynomial(coef), t)

# Polynomial integral
polynomial_integral(s::Int, coef::Vector{Float64}) = polyint(Polynomial(coef))(s)

#= # Calculate polynomial point values
function calculate_polynomial_value(spline::SmoothSpline, times::Vector{Int})
    prices = zeros(Float64, length(times))
    for (i, interval) in enumerate(polynomial_intervals)
        start_time, end_time = interval
        mask = (times .>= start_time) .& (times .<= end_time)
        prices[mask] .= [polynomial_function(time, X[i]) for time in times[mask]]
    end
    return prices
end

# Calculate spline average
function calculate_spline_average(spline::SmoothSpline, start_time::Int, end_time::Int)
    if start_time > end_time
        error("Start is after end")
    end

    if start_time < knots[1] || end_time > knots[end]
        error("Integration bounds are outside the range of the ")
    end

    total_integral = 0.0
    total_duration = end_time - start
    for (i, coefficients) in enumerate(X)
        segment_start = max(start, knots[i])
        segment_end = min(end_time, knots[i+1])

        if segment_start < segment_end
            segment_integral = polynomial_integral(segment_end, coefficients) - polynomial_integral(segment_start, coefficients)
            total_integral += segment_integral
        end
    end

    return total_integral / total_duration
end
 =#
# Calculate H matrix
function calc_H(tau_b::Int, tau_e::Int)
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
function calc_integral_constraint(tau_b::Int, tau_e::Int)
    return [
        (tau_e^5 - tau_b^5) / 5
        (tau_e^4 - tau_b^4) / 4
        (tau_e^3 - tau_b^3) / 3
        (tau_e^2 - tau_b^2) / 2
        tau_e - tau_b
    ]
end

# Calculate knot constraints
function calc_knot_constraints(u_j::Int)
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
        for j in 2:length(knots)
            if tau_e > knots[j-1] && tau_b < knots[j]
                t1 = max(tau_b, knots[j-1])
                t2 = min(knots[j], tau_e)
                A[3*(n-1)+1+i, (5*(j-1)-4):(5*(j-1))] = calc_integral_constraint(t1, t2)
            end
        end
    end

    return A
end


function plot_spline(X::Matrix{Float64}, knots::Vector{Int}, resolution::Int=1000)
    plt = plot()  # Initialize an empty plot
    for (i, coeffs) in enumerate(eachrow(X))
        p = Polynomial(reverse(coeffs))
        interval_start = knots[i]
        interval_end = knots[i+1]

        # Generate points to plot the polynomial
        xs = range(interval_start, stop=interval_end, length=100)
        ys = p.(xs)

        # Plot the polynomial over the interval
        plot!(xs, ys)
    end
    # Display the plot
    display(plt)

end

end