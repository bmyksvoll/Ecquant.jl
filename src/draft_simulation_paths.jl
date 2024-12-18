using XLSX
using Plots
using Random
using Statistics

include("volatility.jl")
include("forwardcurve.jl")

# initial
t = 0.0
T = 1.5  # Total time in years
tau = 1/52
dt = tau  # time step
times = tau:dt:T   # Time step

# Initialize the volatility model
a = 0.26
b = 0.33
c = 0.1

vol_model = BSRModel(a,b,c)

n_steps = length(times)
n_sims = 1000

w = randn(n_sims, n_steps)
f = σ.(Ref(vol_model), t, tau, times)

# Initialize the paths matrix
#Z = zeros(n_sims, n_steps)
P = ones(n_sims, n_steps)

# Iterate through each time step
for (i, t) in enumerate(times)
    Z = exp.(w[:, i] * sqrt(tau) .* f' .- 0.5 .* f'.^2 .* tau)
    P[:, i:end] .= P[:, i:end] .* Z[:, 1:end-i+1]
end

# Plot the paths
plot(times, P', lw=0.2, legend=false, alpha=0.6)

# Calculate volatility from log prices
vol_sim = std(log.(P), dims=1) * sqrt(1/tau)
plot(times, vol_sim')

# Calculate plug-in volatility
plugin_vol = σ.(Ref(vol_model), t, times.-0.01, times,times.+0.01)
plot(times, plugin_vol)

scaler = sqrt.(1.0./times)

vol_sim = std(log.(P), dims=1) .* scaler'
plot!(times, vol_sim')


