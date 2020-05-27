module DungBase

using Dates, UUIDs, StaticArrays
import IntervalSets: width, (..), AbstractInterval, leftendpoint
using StatsBase, StructArrays, Dierckx, AngleBetweenVectors, LinearAlgebra

export VideoFile, WholeVideo, FragmentedVideo, DisjointVideo, AbstractTimeLine, AbstractPeriod, Instantaneous, Prolonged, Temporal, Board, Calibration, POI, Metadata, Run, Experiment, Track, Common, Point, PointCollection

export start, duration, stop, files, filenames, point, pointcollection, homing, searching, searchcenter, turningpoint

__init__() = @warn "This package is deprecated"

stop(x) = start(x) + duration(x)

include("videos.jl")

include("temporals.jl")

include("calibrations.jl")

include("pois.jl")

include("track.jl")

# include(joinpath(@__DIR__, "experimental_setup.jl"))

struct Metadata
    setup::Dict{Symbol, Any}
    comment::String
    date::DateTime
end

# Base.getproperty(x::Metadata, level::Symbol) = get(x.setup, level, missing)
#=getcoord(x::Run, poi::Symbol) = get(x.pois, poi, missing)
_getlevel(x::Metadata, level::Symbol) = get(x, level, missing)
getlevel(x::Run, level::Symbol) = _getlevel(x.metadata, level)=#

struct Run{T, M}
    data::T # pois::Dict{Symbol, T} or Track
    metadata::M
end

#=struct Run
    setup::Dict{Symbol, Any}
    pois::Dict{Symbol, POI}
    comment::String
    date::DateTime
end=#

struct Experiment
    runs::Vector{Run}
    description::String
end

end # module
