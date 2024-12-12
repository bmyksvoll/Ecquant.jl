# Module for maximum smoothness forward curve
using Dates
using Plots
using LinearAlgebra
using Polynomials

include("smoothspline.jl")

const DAYS_PER_YEAR = 365

struct ForwardCurve
	unit::String
	currency::String
	trade_date::DateTime
	instruments::DataFrame
	spline::SmoothSpline

	function ForwardCurve(unit::String, currency::String, trade_date::DateTime, instruments::DataFrame)
		# Calculate the number of days from trade_date to start_date and end_date
		instruments.start_day = Dates.days.(instruments.start_date - trade_date)
		instruments.end_day = Dates.days.(instruments.end_date - trade_date)
		instruments.start_time = instruments.start_day / DAYS_PER_YEAR
		instruments.end_time = instruments.end_day / DAYS_PER_YEAR

		# Create a vector of tuples representing the start and end days
		#taus = collect(zip(instruments.start_day, instruments.end_day))

		# Create a sorted vector of unique days from both start_day and end_day
		#knots = [0; sort(unique(vcat(instruments.start_day, instruments.end_day)))]

		spline = SmoothSpline(instruments.start_time, instruments.end_time, instruments.price)
		new(unit, currency, trade_date, instruments, spline)
	end
end


function plot_curve(forward_curve::ForwardCurve)
	plot_spline(forward_curve.spline)
end

#= 
# Define a function to calculate the difference in years
difference_in_years(start_date::DateTime, end_date::DateTime) = (end_date - start_date).value / (DAYS_PER_YEAR * 24 * 60 * 60 * 1000)

function (fc::ForwardCurve)(times::Vector{Int})
	return fc.spline.calculate_polynomial_value(times)
end

function (fc::ForwardCurve)(start_time::Int, end_time::Int)
	return fc.spline.calculate_spline_average(start_time, end_time)
end


function get_price_intervals(fc::ForwardCurve, interval::Int=7)
	start_days = 0:interval:fc.knots[end]-1
	end_days = min.(start_days .+ interval, fc.knots[end])

	prices = [fc(start_days, end_days) for (start_days, end_days) in zip(start_days, end_days)]

	return hcat(start_days, end_days, prices)
end

function plot(fc::ForwardCurve)
	#plot(title="Maximum smoothness forward curve", xlabel="Time", ylabel="Price", legend=false, size=(800, 400))
	plot_spline(fc.spline)

	for (start_time, end_time, price) in zip(fc.instruments["start"], fc.instruments["end"], fc.instruments["price"])
		plot!([start_time, end_time], [price, price], color="darkgrey", label="")
	end
	display(plot!())
end

 =#
