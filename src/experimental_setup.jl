#=using DataStructures

abstract type AbstractFactor end

struct Nominal <: AbstractFactor
    levels::Set{String}
end

struct Ordinal <: AbstractFactor
    levels::OrderedSet{String}
end

struct Discrete <: AbstractFactor
    levels::OrderedSet{Int}
end

struct Continuous <: AbstractFactor
    levels::Vector{Float64}
end

struct Run
    setup::Int
    start::DateTime
    comment::String
    pois::Vector{POI}
end

struct Experiment{N}
    description::String
    factors::NTuple{N, String}
    levels::NTuple{N, AbstractFactor}
    setups::Vector{NTuple{N, Int}}
    runs::Vector{Run}
end=#


struct Run
    setup::Vector{Union{Missing, String}}
    start::DateTime
    comment::String
    pois::Dict{Symbol, POI}
end

struct Experiment
    description::String
    runs::Vector{Run}
end

