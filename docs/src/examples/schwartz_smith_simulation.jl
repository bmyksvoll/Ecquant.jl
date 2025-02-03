using Ecquant
using LinearAlgebra
using Random

struct SchwarzSmithModel
    kappa_s::Float64
    kappa_l::Float64
    sigma_s::Float64
    sigma_l::Float64
    sigma_y::Float64
    rho_sl::Float64
    rho_sy::Float64
    rho_ly::Float64
end

struct SchwarzSmithSimulation
    model::SchwarzSmithModel
    n_sims::Int
    t::Float64
    tau::Float64
    times::Vector{Float64}
end

function simulate_schwarz_smith(sim::SchwarzSmithSimulation)
    n_steps = length(sim.times)
    dt = sim.tau

    # Initialize paths for the factors
    S = zeros(sim.n_sims, n_steps)
    L = zeros(sim.n_sims, n_steps)
    Y = zeros(sim.n_sims, n_steps)

    # Generate correlated random samples
    rng = MersenneTwister(1234)
    W = randn(rng, sim.n_sims, 3, n_steps)
    L = cholesky([1.0 sim.model.rho_sl sim.model.rho_sy; sim.model.rho_sl 1.0 sim.model.rho_ly; sim.model.rho_sy sim.model.rho_ly 1.0]).L

    for i in 2:n_steps
        dW = L * W[:, :, i] * sqrt(dt)
        S[:, i] = S[:, i-1] - sim.model.kappa_s * S[:, i-1] * dt + sim.model.sigma_s * dW[:, 1]
        L[:, i] = L[:, i-1] - sim.model.kappa_l * L[:, i-1] * dt + sim.model.sigma_l * dW[:, 2]
        Y[:, i] = Y[:, i-1] + sim.model.sigma_y * dW[:, 3]
    end

    # Calculate the price paths
    P = exp.(S .+ L .+ Y)
    return P
end


# Example usage
kappa_s = 0.5
kappa_l = 0.1
sigma_s = 0.2
sigma_l = 0.1
sigma_y = 0.3
rho_sl = 0.5
rho_sy = 0.3
rho_ly = 0.2

model = SchwarzSmithModel(kappa_s, kappa_l, sigma_s, sigma_l, sigma_y, rho_sl, rho_sy, rho_ly)

n_sims = 1000
t = 0.0
tau = Float64(1/252)
times = collect(range(0.0, stop=1.0, step=Float64(1/252)))

sim = SchwarzSmithSimulation(model, n_sims, t, tau, times)

P = simulate_schwarz_smith(sim)
println("Simulated price paths: ", P)