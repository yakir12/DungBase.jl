module DungBase

export VideoFile, WholeVideo, FragmentedVideo, DisjointVideo, AbstractTimeLine, AbstractPeriod, Instantaneous, Prolonged, Temporal, Board, Calibration, POI, Run, Experiment

export start, duration, stop, files, filenames

include("temporals.jl")

include("calibrations.jl")

include("pois.jl")

# include(joinpath(@__DIR__, "experimental_setup.jl"))

struct Run
    pois::Dict{Symbol, POI}
    setup::Dict{Symbol, Any}
    date::Date
    comment::String
end

struct Experiment
    runs::Vector{Run}
    description::String
end

end # module
