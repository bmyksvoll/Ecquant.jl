# Module for maximum smoothness forward curve
module ForwardCurve

using Dates
using Plots
using LinearAlgebra
using Polynomials

include("SmoothSpline.jl")

const DAYS_PER_YEAR = 365.25

#= struct ForwardCurve
    unit::String
    currency::String
    trade_date::DateTime
    instruments::Dict
    taus::Vector{Tuple{Int,Int}}
    knots::Vector{Int}
    prices::Vector{Float64}
    spline::SmoothSpline

    function ForwardCurve(unit::String, currency::String, trade_date::DateTime, instruments::Dict)
        instruments["start"] = [Dates.days(start_date - trade_date) for start_date in instruments["start_date"]]
        instruments["end"] = [Dates.days(end_date - trade_date) for end_date in instruments["end_date"]]

        taus = collect(zip(instruments["start"], instruments["end"]))
        knots = [0; sort(unique(vcat(instruments["start"], instruments["end"])))]
        prices = instruments["price"]
        spline = SmoothSpline(taus, knots, prices)

        new(unit, currency, trade_date, instruments, taus, knots, prices, spline)
    end
end
 =#
# Define a function to calculate the difference in years
difference_in_years(start_date::DateTime, end_date::DateTime) = (end_date - start_date).value / (DAYS_PER_YEAR * 24 * 60 * 60 * 1000)

function (fc::ForwardCurve)(times::Vector{Int})
    return fc.spline.calculate_polynomial_value(times)
end

function (fc::ForwardCurve)(start_time::Int, end_time::Int)
    return fc.spline.calculate_spline_average(start_time, end_time)
end

#= 
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
end