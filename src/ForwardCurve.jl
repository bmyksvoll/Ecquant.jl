# Module for maximum smoothness forward curve
using Dates
using Plots
using LinearAlgebra
using Polynomials
using DataFrames

include("smoothspline.jl")

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

function price(forward_curve::ForwardCurve, times::Float64)
	price(forward_curve.spline, times)
end

function plot_curve(forward_curve::ForwardCurve)
	plot_spline(forward_curve.spline)
end
