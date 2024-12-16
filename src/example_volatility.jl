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
tau = 1/52
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

f1 = sigma_factor1.(Ref(model), 0.0, tau, times)
f2 = sigma_factor2.(Ref(model), 0.0, tau, times)
f3 = sigma_factor3.(Ref(model), times)
# Test consistency between 

vol_factors = sqrt.(f1.^2+ f2.^2 .+ f3.^2)

# Test consistency between single and three-factor model
plot(times, vol)
plot!(times, vol_factors)


