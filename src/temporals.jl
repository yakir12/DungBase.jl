using Dates

struct VideoFile
    name::String
    start::DateTime
    duration::Nanosecond

    function VideoFile(name, start, duration)
        @assert !isempty(name) "file name is empty"
        @assert start > DateTime(0) "starting date & time must be larger than zero"
        @assert duration > Nanosecond(0) "zero duration is not supported"
        new(name, start, duration)
    end

end

start(x::VideoFile) = x.start
duration(x::VideoFile) = x.duration
stop(x) = start(x) + duration(x)

abstract type AbstractTimeLine end

struct WholeVideo <: AbstractTimeLine
    file::VideoFile
    comment::String
end

files(x::WholeVideo) = [x.file]

struct FragmentedVideo <: AbstractTimeLine
    files::Vector{VideoFile}
    comment::String

    function FragmentedVideo(files, comment) 
        @assert length(files) > 1 "video collection must include more than one file"
        last = stop(files[1])
        for file in files[2:end]
            @assert start(file) == last "there is a gap between two adjacent videos"
            last = stop(file)
        end
        new(files, comment)
    end

end

struct DisjointVideo <: AbstractTimeLine
    files::Vector{VideoFile}
    comment::String

    function DisjointVideo(files, comment) 
        @assert length(files) > 1 "video collection must include more than one file"
        last = stop(files[1])
        for file in files[2:end]
            @assert start(file) ≥ last "one file starts before the next one ends"
            last = stop(file)
        end
        new(files, comment)
    end

end

files(x::AbstractTimeLine) = x.files

filenames(x::AbstractTimeLine) = getfield.(files(x), :name)

start(x::WholeVideo) = start(x.file)
start(x::AbstractTimeLine) = start(first(x.files))
duration(x::WholeVideo) = duration(x.file)
duration(x::FragmentedVideo) = sum(duration, x.files)
duration(x::DisjointVideo) = stop(last(x.files)) - start(first(x.files))

abstract type AbstractPeriod end

struct Instantaneous <: AbstractPeriod
    anchor::Nanosecond
end

struct Prolonged <: AbstractPeriod
    anchor::Nanosecond
    duration::Nanosecond

    function Prolonged(anchor, duration)
        @assert duration > Nanosecond(0) "period duration must be larger than zero"
        new(anchor, duration)
    end

end

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
