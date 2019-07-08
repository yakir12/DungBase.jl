abstract type AbstractPeriod end

struct Instantaneous <: AbstractPeriod
    anchor::Millisecond
end

Instantaneous() = Instantaneous(Millisecond(0))

struct Prolonged <: AbstractPeriod
    anchor::Millisecond
    duration::Millisecond

    function Prolonged(anchor, duration)
        @assert anchor ≥ Millisecond(0) "period start cannot be negative"
        @assert duration > Millisecond(0) "period duration must be larger than zero"
        new(anchor, duration)
    end

end

Prolonged() = Prolonged(Millisecond(0), Millisecond(1))

AbstractPeriod(start, _::Missing) = Instantaneous(start)
AbstractPeriod(start, stop) = Prolonged(start, Millisecond(stop) - start)

start(x::AbstractPeriod) = x.anchor
duration(_::Instantaneous) = Millisecond(0)
duration(x::Prolonged) = x.duration

struct Temporal{V <: AbstractTimeLine, T <: AbstractPeriod}
    video::V
    time::T
    comment::String

    function Temporal{V, T}(video, time, comment) where {V <: AbstractTimeLine, T <: AbstractPeriod}
        @assert stop(time) ≤ duration(video) "POIs are outside the video's timeline"
        new(video, time, comment)
    end

end
Temporal(video::V, time::T, comment::String) where {V <: AbstractTimeLine, T <: AbstractPeriod} = Temporal{V, T}(video, time, comment)

Temporal() = Temporal(WholeVideo(), Instantaneous(), "")
