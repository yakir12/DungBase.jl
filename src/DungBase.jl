module DungBase

using UUIDs, Dates

export VideoFile, WholeVideo, FragmentedVideo, DisjointVideo, AbstractTimeLine, AbstractPeriod, Instantaneous, Prolonged, Temporal, Board, Calibration, POI, Run, Experiment

export start, duration, stop, files, filenames

stop(x) = start(x) + duration(x)

include("videos.jl")

include("temporals.jl")

include("calibrations.jl")

include("pois.jl")

# include(joinpath(@__DIR__, "experimental_setup.jl"))

struct Run
    setup::Dict{Symbol, Any}
    pois::Dict{Symbol, POI}
    comment::String
end

struct Experiment
    runs::Vector{Run}
    description::String
end

end # module
