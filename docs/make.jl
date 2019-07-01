using Documenter, DungBase

makedocs(
    modules = [DungBase],
    format = :html,
    sitename = "DungBase.jl",
    pages = Any["index.md"]
)

deploydocs(
    repo = "github.com/yakir12/DungBase.jl.git",
    target = "build",
    julia = "1.0",
    deps = nothing,
    make = nothing,
)
