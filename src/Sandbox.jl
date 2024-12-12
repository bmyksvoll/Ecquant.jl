# %%

using Dates
using DataFrames
using XLSX
using Plots
using Polynomials

include("forwardcurve.jl")


trade_date = DateTime(2021, 6, 17)

# Create a vector of Instrument instances
# Define the DataFrame row-wise using a vector of named tuples
instruments = DataFrame([
	(isActive = true, name = "JUL-21", start_date = DateTime(2021, 7, 1), end_date = DateTime(2021, 8, 1), price = 32.55),
	(isActive = true, name = "AUG-21", start_date = DateTime(2021, 8, 1), end_date = DateTime(2021, 9, 1), price = 32.5),
	(isActive = true, name = "SEP-21", start_date = DateTime(2021, 9, 1), end_date = DateTime(2021, 10, 1), price = 32.5),
	(isActive = true, name = "OCT-21", start_date = DateTime(2021, 10, 1), end_date = DateTime(2021, 11, 1), price = 32.08),
	(isActive = true, name = "NOV-21", start_date = DateTime(2021, 11, 1), end_date = DateTime(2021, 12, 1), price = 36.88),
	(isActive = true, name = "DEC-21", start_date = DateTime(2021, 12, 1), end_date = DateTime(2022, 1, 1), price = 39.8),
	(isActive = true, name = "Q1-22", start_date = DateTime(2022, 1, 1), end_date = DateTime(2022, 4, 1), price = 39.4),
	(isActive = true, name = "Q2-22", start_date = DateTime(2022, 4, 1), end_date = DateTime(2022, 7, 1), price = 25.2),
	(isActive = true, name = "Q3-22", start_date = DateTime(2022, 7, 1), end_date = DateTime(2022, 10, 1), price = 21.15),
	(isActive = true, name = "Q4-22", start_date = DateTime(2022, 10, 1), end_date = DateTime(2023, 1, 1), price = 29.5),
])

# Create an instance of ForwardCurve
forward_curve = ForwardCurve("USD", "MWh", trade_date, instruments)

forward_curve.instruments

plot_curve(forward_curve)
# ------------------------------------------------ Old stuff ----------------------
#= 
instruments = Dict(
	"include" => [true for _ in 1:10],
	"name" => ["JUL-21", "AUG-21", "SEP-21", "OCT-21", "NOV-21", "DEC-21", "Q1-22", "Q2-22", "Q3-22", "Q4-22"],
	"start_date" => [
		DateTime(2021, 7, 1), DateTime(2021, 8, 1), DateTime(2021, 9, 1),
		DateTime(2021, 10, 1), DateTime(2021, 11, 1), DateTime(2021, 12, 1),
		DateTime(2022, 1, 1), DateTime(2022, 4, 1), DateTime(2022, 7, 1),
		DateTime(2022, 10, 1),
	],
	"end_date" => [
		DateTime(2021, 8, 1), DateTime(2021, 9, 1),
		DateTime(2021, 10, 1), DateTime(2021, 11, 1),
		DateTime(2021, 12, 1), DateTime(2022, 1, 1),
		DateTime(2022, 4, 1), DateTime(2022, 7, 1),
		DateTime(2022, 10, 1), DateTime(2023, 1, 1),
	],
	"price" => [32.55, 32.5, 32.5, 32.08, 36.88, 39.8, 39.4, 25.2, 21.15, 29.5],
)

#fc = ForwardCurve("MWh", "EUR", trade_date, instruments)

instruments["start_day"] = [Dates.days(start_date - trade_date) for start_date in instruments["start_date"]]
instruments["end_day"] = [Dates.days(end_date - trade_date) for end_date in instruments["end_date"]]

taus = collect(zip(instruments["start_day"], instruments["end_day"]))
knots = [0; sort(unique(vcat(instruments["start_day"], instruments["end_day"])))]
prices = instruments["price"]
n = length(knots) - 1
m = length(taus)

instruments

spline = SmoothSpline(taus, knots, prices)
plot_spline(spline.X, knots, 1000)









# Calculate the average prices using a list comprehension
instruments["calc_price"] = [average_price(spline, start_day, end_day) for (start_day, end_day) in zip(instruments["start_day"], instruments["end_day"])]

DataFrame(instruments)
#XLSX.writetable("X_mat.xlsx", X_df)


# Plot each polynomial over its interval





 =#
