using Plots
using Ecquant

function calibrate_sigma(sigma_0, sigma_mid, sigma_inf, t_mid)
    # Calculate c directly from the value of sigma at infinity
    c = sigma_inf

    # Calculate b using the derived formula
    b = (sigma_mid - sigma_inf) * t_mid / (sigma_0 - sigma_mid)

    # Calculate a using the derived formula
    a = b * (sigma_0 - sigma_inf)

    return a, b, c
end


sigma_0 = 0.9    # Replace with the actual value of sigma at t = 0
sigma_mid = 0.17  # Replace with the actual value of sigma at t = t_mid
sigma_inf = 0.1  # Replace with the actual value of sigma at t = inf
t_mid = 0.5     # Replace with the actual value of t_mid

a, b, c = calibrate_sigma(sigma_0, sigma_mid, sigma_inf, t_mid)

println("Calibrated parameters:")
println("a = $a")
println("b = $b")
println("c = $c")

# Initialize the model
model = BSRVolatilityModel(a,b,c)



t = 0.0
T = 1.5
tau = 1E-3
stepsize = tau

# Create the range of t values
times = tau:stepsize:T

# Calculate the instantaneous volatility for each t value
vol_instant = σ.(Ref(model), t, times)

# Calculate the volatility over time for small tau
vol = σ.(Ref(model), t, tau, times)

# Calculate the plug-in volatility 
vol_plugin = σ.(Ref(model), t, tau, times, times.+tau)

all(isapprox.(vol, vol_instant,atol=1e-2))

# Assuming vol and t have been calculated as shown previously
plot(times, vol_instant, label="Instantaneous Volatility", xlabel="Time (t)", ylabel="Volatility (σ)", title="Instantaneous Volatility over Time")
plot!(times, vol)
