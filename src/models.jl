using Plots
using Random
using Distributions

include("volatility.jl")
include("forwardcurve.jl")
include("simulation.jl")

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
fc = ForwardCurve("USD", "MWh", trade_date, instruments)

T = 1.5  # Total time in years
dt = 1/365  # Daily time step
tau = 1/52
times = 0:dt:T-dt   # Time steps

# Assuming fc is an instance with a method calc_smooth_price
term_structure_initial = price.(Ref(fc), times)

# Create an instance of the Simulation class
vol = BSRModel()
sim = Simulation(100, tau, vol, term_structure_initial, times)

# Run the simulation
sim_curves = run_simulation(sim)

# Plot the initial term structure
plot(times, term_structure_initial, color=:black, lw=2, label="Term Structure")

plot!(times, sim_curves', lw=0.1, legend=false, color=:blue, alpha=0.5)