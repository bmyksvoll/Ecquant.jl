# Define the Simulation class
struct BSRSimulation
    fc::ForwardCurve
    vol::BSRModel
    n_sims::Int
    t::Float64
    tau::Float64
    times::Vector{Float64}
end

struct BSRPathSimulation
    fc::ForwardCurve
    vol::BSRModel
    n_sims::Int
    n_steps::Int
    t::Float64
    tau::Float64
    times::Vector{Float64}
end

function simulate_singlefactor(sim::BSRSimulation)
    # Generate independent random samples
    w = randn(sim.n_sims, 1)
    f = σ.(Ref(sim.vol), sim.t, sim.tau, sim.times)
    Z = exp.(w * sqrt(sim.tau) .* f' .- 0.5 .* f'.^2 .* sim.tau)
    return Z
end


function simulate_multifactor(sim::BSRSimulation)
    # Generate independent random samples
    w = randn(sim.n_sims, 3)
    f1 = σ₁.(Ref(sim.vol), sim.t, sim.tau, sim.times)
    f2 = σ₂.(Ref(sim.vol), sim.t, sim.tau, sim.times)
    f3 = σ₃.(Ref(sim.vol), sim.times)
    z1 = exp.(w[:, 1] * sqrt(sim.tau) .* f1' .- 0.5 .* f1'.^2 .* sim.tau)
    z2 = exp.(w[:, 2] * sqrt(sim.tau) .* f2' .- 0.5 .* f2'.^2 .* sim.tau)
    z3 = exp.(w[:, 3] * sqrt(sim.tau) .* f3' .- 0.5 .* f3'.^2 .* sim.tau)
    Z = z1 .* z2 .* z3
    return Z
end


function simulate_singlefactor_path(sim::BSRPathSimulation)
    # Set a seed for reproducibility
    seed = 1234
    rng = MersenneTwister(seed)

    # Generate independent random samples
    w = randn(rng, sim.n_sims, sim.n_steps)
    
    # Calculate the volatility term structure
    vol = σ.(Ref(sim.vol), sim.t,sim.tau, sim.times)
    
    # Initialize the paths matrix
    P = ones(sim.n_sims, sim.n_steps)

    # Iterate through each time step
    for (i, t) in enumerate(sim.times)
        Z = exp.(w[:, i] * sqrt(sim.tau) .* vol' .- 0.5 .* vol'.^2 .* sim.tau)
        P[:, i:end] .= P[:, i:end] .* Z[:, 1:end-i+1]
    end

    return P

    #sim_paths = P .* fc'
end
