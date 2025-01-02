module Ecquant

# Import necessary packages
using Dates
using CSV
using DataFrames
using Plots
using Random
using StatsBase
using PolyLog:reli2
using LinearAlgebra
using Polynomials
using Random
using BlockDiagonals

# Include other source files
include("smoothspline.jl")
include("forwardcurve.jl")
include("volatility.jl")
include("simulation.jl")

# Export functions and types that should be accessible to users of the package
export BSRModel, ForwardCurve, simulate_singlefactor, simulate_multifactor, simulate_singlefactor_path
export BSRSimulation, BSRPathSimulation
export smoothspline, forwardcurve, volatility, simulation,  plot_curve
export σ, σ₁, σ₂, σ₃, price

# Define any additional functions or types here if needed

end # module Ecquant