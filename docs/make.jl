# docs/make.jl
using Documenter
using Ecquant

makedocs(
    sitename = "Ecquant Documentation",
    modules = [Ecquant],
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md",
    ]
)