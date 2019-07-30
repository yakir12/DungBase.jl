abstract type AbstractPeriod end

function checkInstantaneous(x::T) where {T <: TimePeriod}
    @assert x ≥ zero(T) "period start cannot be negative"
    x
end

checkInstantaneous(x) = x
struct Instantaneous{T} <: AbstractPeriod
    data::T
    Instantaneous{T}(x) where {T} = new(checkInstantaneous(x))
end
Instantaneous(x::T) where {T} = Instantaneous{T}(x)

Instantaneous() = Instantaneous(Millisecond(0))

function checkProlonged(x::I)  where {T <: TimePeriod, I <: AbstractInterval{T}}
    @assert leftendpoint(x) ≥ zero(T) "period start cannot be negative"
    @assert width(x) > zero(T) "period duration must be larger than zero"
    x
end

checkProlonged(x) = x

struct Prolonged{T} <: AbstractPeriod
    data::T
    Prolonged{T}(x) where {T} = new(checkProlonged(x))
end
Prolonged(x::T) where {T} = Prolonged{T}(x)

Prolonged() = Prolonged(Millisecond(0)..Millisecond(1))

AbstractPeriod(start::T) where {T <: TimePeriod} = Instantaneous(start)
AbstractPeriod(x::I) where {T <: TimePeriod, I <: AbstractInterval{T}} = Prolonged(x)
AbstractPeriod(start::T1, stop::T2) where {T1 <: TimePeriod, T2 <: TimePeriod} = Prolonged(start..stop)
AbstractPeriod(start::T, _::Nothing) where {T <: TimePeriod} = Instantaneous(start)

start(x::Instantaneous) = x.data
start(x::Prolonged) = leftendpoint(x.data)
duration(x::Instantaneous{T}) where {T <: TimePeriod} = zero(T)
duration(x::Prolonged) = width(x.data)

struct Temporal{V <: AbstractTimeLine, T <: AbstractPeriod}
    video::V
    time::T
    comment::String

    function Temporal{V, T}(video, time, comment) where {V <: AbstractTimeLine, T <: AbstractPeriod}
        @assert stop(time) ≤ duration(video) "POIs are outside the video's timeline (stop: $(stop(time)); duration: $(duration(video)); file: $(files(video))"
        new(video, time, comment)
    end

end
Temporal(video::V, time::T, comment::String) where {V <: AbstractTimeLine, T <: AbstractPeriod} = Temporal{V, T}(video, time, comment)

Temporal() = Temporal(WholeVideo(), Instantaneous(), "")
