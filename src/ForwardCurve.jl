# Module for maximum smoothness forward curve
#include("smoothspline.jl")

const DAYS_PER_YEAR = 365

struct ForwardCurve
	unit::String
	currency::String
	trade_date::DateTime
	instruments::DataFrame
	spline::SmoothSpline

	function ForwardCurve(unit::String, currency::String, trade_date::DateTime, instruments::DataFrame)
		# Calculate year fraction from the number of days from trade_date to start_date and end_date divided by DAYS_PER_YEAR.
		instruments.start_time = Dates.days.(instruments.start_date - trade_date) / DAYS_PER_YEAR
		instruments.end_time = Dates.days.(instruments.end_date - trade_date) / DAYS_PER_YEAR
		spline = SmoothSpline(instruments.start_time, instruments.end_time, instruments.price)
		new(unit, currency, trade_date, instruments, spline)
	end
end

# Calculate price for a given time
function price(forward_curve::ForwardCurve, times::Float64)
	price(forward_curve.spline, times)
end

# Calculate price for a given time interval
function price(forward_curve::ForwardCurve, start_time::Float64, end_time::Float64)
	price(forward_curve.spline, start_time, end_time)
end

function plot_curve(forward_curve::ForwardCurve)
	plt = plot_spline(forward_curve.spline)
	# Iterate over the start_date, end_date, and price using zip and enumerate
	for (i, (start_time, end_time, price)) in enumerate(zip(forward_curve.instruments.start_time, forward_curve.instruments.end_time, forward_curve.instruments.price))
		name = forward_curve.instruments.name[i]
		# Plot a horizontal line for the price of the instrument
		plot!(plt, [start_time, end_time], [price, price], label = name, lw = 2)
	end

	# Display the plot
	display(plt)
end
