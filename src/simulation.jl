# Define the Simulation class
struct Simulation
    n_sims::Int
    tau::Float64
    vol::BSRModel
    term_structure_initial::Vector{Float64}
    times::Vector{Float64}
end

function run_simulation(sim::Simulation)
    # Generate independent random samples
    w = randn(sim.n_sims, 3)

    f1 = sigma_factor1.(Ref(sim.vol), 0.0, sim.tau, sim.times)
    f2 = sigma_factor2.(Ref(sim.vol), 0.0, sim.tau, sim.times)
    f3 = sigma_factor3.(Ref(sim.vol), sim.times)

    z1 = exp.(w[:, 1] * sqrt(sim.tau) .* f1' .- 0.5 .* f1'.^2 .* sim.tau)
    z2 = exp.(w[:, 2] * sqrt(sim.tau) .* f2' .- 0.5 .* f2'.^2 .* sim.tau)
    z3 = exp.(w[:, 3] * sqrt(sim.tau) .* f3' .- 0.5 .* f3'.^2 .* sim.tau)

    Z = z1 .* z2 .* z3

    sim_curves = Z .* sim.term_structure_initial'
    return sim_curves
end
