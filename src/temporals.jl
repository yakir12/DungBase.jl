struct Interval
    start::Nanosecond
    duration::Nanosecond

    function Interval(start, duration)
        @assert start ≥ Nanosecond(0) "period start must be positive"
        @assert duration > Nanosecond(0) "period duration must be larger than zero"
        new(start, duration)
    end

end

start(x::Interval) = x.start
duration(x::Interval) = x.duration

Interval() = Interval(Nanosecond(0), Nanosecond(1))
Interval(p::Interval, args) = Interval(get(args, :start, start(p)), get(args, :duration, duration(p)))

struct Temporal{V <: AbstractVideo}
    video::V
    time::Interval
    comment::String

    function Temporal{V}(video, time, comment) where {V <: AbstractVideo}
        @assert stop(time) ≤ duration(video) "POIs are outside the video's timeline"
        new(video, time, comment)
    end

end
Temporal(video::V, time::Interval, comment::String) where {V <: AbstractVideo} = Temporal{V}(video, time, comment)

Temporal() = Temporal(WholeVideo(), Instantaneous(), "")

Temporal(t::Temporal{V}, args) where {V <: AbstractVideo} = Temporal(get(args, :video, V(t.video, args)), get(args, :time, T(t.time, args)), get(args, :comment, t.comment))





#=abstract type AbstractPeriod end

struct Instantaneous <: AbstractPeriod
    anchor::Nanosecond
end

Instantaneous() = Instantaneous(Nanosecond(0))

Instantaneous(i::Instantaneous, args) = Instantaneous(get(args, :anchor, i.anchor))

struct Prolonged <: AbstractPeriod
    anchor::Nanosecond
    duration::Nanosecond

    function Prolonged(anchor, duration)
        @assert duration > Nanosecond(0) "period duration must be larger than zero"
        new(anchor, duration)
    end

end

Prolonged() = Prolonged(Nanosecond(0), Nanosecond(1))

Prolonged(p::Prolonged, args) = Prolonged(get(args, :anchor, p.anchor), get(args, :duration, p.duration))

AbstractPeriod(start, _::Missing) = Instantaneous(start)
AbstractPeriod(start, stop) = Prolonged(start, Nanosecond(stop) - start)

start(x::AbstractPeriod) = x.anchor
duration(_::Instantaneous) = Nanosecond(0)
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

Temporal(t::Temporal{V,T}, args) where {V <: AbstractTimeLine, T <: AbstractPeriod} = Temporal(get(args, :video, V(t.video, args)), get(args, :time, T(t.time, args)), get(args, :comment, t.comment))=#
