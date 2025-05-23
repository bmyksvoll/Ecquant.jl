# NEED TO CHECK  TIME INDEX CONSISTENCY BETWEEN PLUG-IN AND SIMULATION
#using XLSX
using Dates: DateTime
using StatsBase: std, mean
using DataFrames
using Plots
using Random
using Ecquant


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


# Initialize time and time step
t = 0.0 # Start time
T = 1.5  # Total time in years
tau = 1/52 
times = tau:tau:T   # Time step
Δ = 1E-5

# Create an instance of ForwardCurve
fc_model = ForwardCurve("USD", "MWh", trade_date, instruments)
fc = price.(Ref(fc_model), times)

# Initialize the volatility model
a = 0.26
b = 0.33
c = 0.1

vol_model = BSRVolatilityModel(a,b,c)
vol = σ.(Ref(vol_model), t, tau, times)
vol_plugin = σ.(Ref(vol_model), t, times.-Δ, times, times.+Δ)

#= To improve the random number generation in  simulation,

 - Set a Seed for Reproducibility: Setting a seed ensures that 
 the random number generation is reproducible,  which is useful
 for debugging and testing.
 - Use MersenneTwister for Better Performance: The MersenneTwister 
 random number generator is a good choice for simulations due to
 its performance and quality.
 =#

# Set up the simulation parameters
n_steps = length(times)
n_sims = 10000

# Set a seed for reproducibility
seed = 1234
rng = MersenneTwister(seed)

# Generate independent random samples
w = randn(rng, n_sims, n_steps)

# Initialize the paths matrix

P = ones(n_sims, n_steps)
# Iterate through each time step
for (i, t) in enumerate(times)
    Z = exp.(w[:, i] * sqrt(tau) .* vol' .- 0.5 .* vol'.^2 .* tau)
    P[:, i:end] .= P[:, i:end] .* Z[:, 1:end-i+1]
end

#vol_sim = std(log.(P), dims=1) .* sqrt.(1.0./times)'
#sim = BSRPathSimulation(fc, vol_model, n_sims, n_steps, t, tau, times)
sim_paths = P .* fc'
vol_sim = std(log.(sim_paths), dims=1) .* sqrt.(1.0./times)'
mean_sim = mean(sim_paths, dims=1)

# Plot the paths
plot1 = plot(times, sim_paths', lw=0.2, legend=false, alpha=0.6, title="Simulated Price Paths & Forward Curve", size=(800, 500))
plot!(plot1, times, fc, lw=1, label= "Forward Curve", color=:blue, alpha=0.6)

# Annotate the plot with the number of simulations, horizon T and timestep tau
annotate!(plot1, (1, 100, text("Simulations: $n_sims", :left, 10, :black)))
annotate!(plot1, (1, 60, text("Horizon (T): $T years", :left, 10, :black)))

# Plot the input and simulated volatility
plot2 = plot(times, vol_plugin, lw=2, label="Plug-in Volatility", title="Validation of simulated volatiliity", size=(800, 500))
plot!(plot2, times, vol_sim', lw=2, label="Simulation Volatility")

# Plot the input and simulated volatility
plot3 = plot(times, fc, lw=2, label="Forward Curve", title="Validation of No Arbitrage", size=(800, 500))
plot!(plot3, times, mean_sim', lw=2, label="Simulation Volatility")


# Display the plots
plot(plot1, plot2, plot3, layout=(3, 1), size=(800, 1000))

