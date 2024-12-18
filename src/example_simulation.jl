using XLSX
using Plots
using Random
#using Distributions
using Statistics

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

# initial
t = 0.0
T = 1.5  # Total time in years
tau = 1/52
dt = tau  # time step
times = tau:dt:T   # Time step

# Create an instance of ForwardCurve
fc = ForwardCurve("USD", "MWh", trade_date, instruments)
# Assuming fc is an instance with a method calc_smooth_price
term_structure_initial = price.(Ref(fc), times)

# Initialize the volatility model
a = 0.26
b = 0.33
c = 0.1

vol_model = BSRModel(a,b,c)
vol = σ.(Ref(vol_model), t, tau, times)

# Create an instance of the Simulation class
nsim = 1000
sim = BSRSimulation(fc, vol_model, nsim, t, tau, times)

# Run singlefactor simulation
shocks = simulate_singlefactor(sim)
sim_curves = shocks .* term_structure_initial'

# Plot the initial term structure
plot(times, term_structure_initial, color=:blue, lw=2, label="Term Structure")
plot!(times, sim_curves', lw=0.1, legend=false, alpha=0.5)

# Validate consistency between the volatility model and the simulation volatility
vol_sim = vec(std(log.(shocks), dims=1) * sqrt(1/tau))

# Plot input and simulated volatility
plot(times, vol, lw=1, legend=true, label = "Input Volatility")
plot!(times, vol_sim, lw=1, color=:red, alpha = 0.5, label="Simulated Volatility")

all(isapprox.(vol, vol_sim, atol=1E-2))

# Run multi-factor simulation

shocks = simulate_multifactor(sim)
sim_curves = shocks .* term_structure_initial'

# Plot the initial term structure
plot(times, term_structure_initial, color=:blue, lw=2, label="Term Structure")
plot!(times, sim_curves', lw=0.1, legend=false, alpha=0.5)


# Calculate standard deviation of the logreturn of shocks, scaled to annualised volatility.
vol_sim = vec(std(log.(shocks), dims=1) * sqrt(1/tau))


# Plot input and simulated volatility
plot(times, vol, lw=1, legend=true, label = "Input Volatility")
plot!(times, vol_sim, lw=1, color=:red, alpha = 0.5, label="Simulated Volatility")

# Validate consistency between the volatility model and the simulation volatility
all(isapprox.(vol, vol_sim, atol=1E-2))