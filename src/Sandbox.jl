module Sandbox

using Dates
using DataFrames
using XLSX
using Plots
using Polynomials

#include("ForwardCurve.jl")
include("SmoothSpline.jl")

# Example usage
trade_date = DateTime(2021, 6, 17)

instruments = Dict(
    "include" => [true for _ in 1:10],
    "name" => ["JUL-21", "AUG-21", "SEP-21", "OCT-21", "NOV-21", "DEC-21", "Q1-22", "Q2-22", "Q3-22", "Q4-22"],
    "start_date" => [
        DateTime(2021, 7, 1), DateTime(2021, 8, 1), DateTime(2021, 9, 1),
        DateTime(2021, 10, 1), DateTime(2021, 11, 1), DateTime(2021, 12, 1),
        DateTime(2022, 1, 1), DateTime(2022, 4, 1), DateTime(2022, 7, 1),
        DateTime(2022, 10, 1)
    ],
    "end_date" => [
        DateTime(2021, 8, 1), DateTime(2021, 9, 1),
        DateTime(2021, 10, 1), DateTime(2021, 11, 1),
        DateTime(2021, 12, 1), DateTime(2022, 1, 1),
        DateTime(2022, 4, 1), DateTime(2022, 7, 10),
        DateTime(2022, 10, 1), DateTime(2023, 1, 1)
    ],
    "price" => [32.55, 32.5, 32.5, 32.08, 36.88, 39.8, 39.4, 25.2, 21.15, 29.5]
)



#fc = ForwardCurve("MWh", "EUR", trade_date, instruments)

instruments["start"] = [Dates.days(start_date - trade_date) for start_date in instruments["start_date"]]
instruments["end"] = [Dates.days(end_date - trade_date) for end_date in instruments["end_date"]]

taus = collect(zip(instruments["start"], instruments["end"]))
knots = [0; sort(unique(vcat(instruments["start"], instruments["end"])))]
prices = instruments["price"]
n = length(knots) - 1
m = length(taus)

H = SmoothSpline.calc_big_H(knots, n)
A = SmoothSpline.calc_big_A(taus, knots, m, n)
B = SmoothSpline.calc_B(taus, prices, m, n)

#H_df = DataFrame(H_mat, :auto)
#XLSX.writetable("A_mat.xlsx", H_df)
top = hcat(2 * H, transpose(A))
btm = hcat(A, zeros(size(A, 1), size(transpose(A), 2)))
A_merged = vcat(top, btm)
B_merged = vcat(zeros(size(top, 2) - length(B)), B)
X = A_merged \ B_merged
transpose(reshape(X[1:n*5], 5, n))


X = SmoothSpline.solve_lineq(n, H, A, B)

SmoothSpline.plot_spline(X, knots, 1000)


#XLSX.writetable("X_mat.xlsx", X_df)


# Plot each polynomial over its interval




end

