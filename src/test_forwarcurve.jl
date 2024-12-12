# %%

using Dates
using DataFrames
using XLSX
using Plots
using Polynomials
using CSV

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



plot_curve(forward_curve)

# Apply the average_price function to each set of start_time, end_time, and price using broadcasting
instruments.calc_price = average_price.(Ref(forward_curve.spline), instruments.start_time, instruments.end_time)

all(isapprox.(instruments.price, instruments.calc_price, atol=1e-10))

all(instruments.price .== instruments.calc_price)

# Iterate over the start_date, end_date, and price using zip and enumerate
for (i, (start_time, end_time, price)) in enumerate(zip(instruments.start_time, instruments.end_time, instruments.price))
	calc_price = average_price(forward_curve.spline, start_time, end_time)
	println(calc_price)
end

#XLSX.writetable("X_mat.xlsx", X_df)
