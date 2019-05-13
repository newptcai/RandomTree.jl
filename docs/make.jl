using Documenter
using RandomTree

makedocs(
    sitename="RandomTree.jl",
    modules = [RandomTree],
    pages = [
        "index.md",
        "Installation" => "install.md",
        "Usage" => "usage.md",
        "API reference" => "api.md",
        "Future Plan" => "plan.md",
    ]
)

deploydocs(
    repo = "github.com/newptcai/RandomTree.jl.git",
)
