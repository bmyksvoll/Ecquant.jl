using Plots

include("volatility.jl")

a = 0.26
b = 0.33
c = 0.1

# Initialize the model
model = BSRModel(a,b,c)

# Define the parameters
t = 0.0
T = 1.0
tau = 1.0E-3
stepsize = 1/365

# Create the range of t values
times = stepsize:stepsize:T
times_tau =times.-tau
times.+tau

# Calculate the instantaneous volatility for each t value
vol_instant = sigma_instant.(Ref(model), t, times)

# Calculate the volatility over time for small tau
vol = sigma.(Ref(model), t, tau, times)

sigma_plugin(model, t, 0.9,  1.0, 2.0)

vol_plugin = sigma_plugin.(Ref(model), t, tau, times, times.+tau)

all(isapprox.(vol, vol_instant,atol=1e-5))



# Assuming vol and t have been calculated as shown previously
plot(times, vol_instant, label="Instantaneous Volatility", xlabel="Time (t)", ylabel="Volatility (σ)", title="Instantaneous Volatility over Time")
plot!(times, vol)
plot!(times, vol_plugin)

