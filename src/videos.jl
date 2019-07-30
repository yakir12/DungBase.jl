struct VideoFile
    name::String
    start::DateTime
    duration::Millisecond

    function VideoFile(name, start, duration)
        @assert !isempty(name) "file name is empty"
        @assert start > DateTime(0) "starting date & time must be larger than zero"
        @assert duration > Millisecond(0) "zero duration is not supported"
        new(name, start, duration)
    end

end

VideoFile() = VideoFile("_", DateTime(1), Millisecond(1))

start(x::VideoFile) = x.start
duration(x::VideoFile) = x.duration

VideoFile(vf::VideoFile, args) = VideoFile(get(args, :name, vf.name), get(args, :start, start(vf)), get(args, :duration, duration(vf)))

abstract type AbstractTimeLine end

struct WholeVideo <: AbstractTimeLine
    file::VideoFile
    comment::String
end

WholeVideo() = WholeVideo(VideoFile(), "")

WholeVideo(wv::WholeVideo, args) = WholeVideo(get(args, :files, VideoFile(wv.file, args)), get(args, :comment, wv.comment))

files(x::WholeVideo) = SVector{1, VideoFile}(x.file)

struct FragmentedVideo{N, SV <: SVector{N, VideoFile}} <: AbstractTimeLine
    files::SV
    comment::String

    function FragmentedVideo{N, SV}(files, comment) where {N, SV <: SVector{N, VideoFile}}
        @assert N > 1 "video collection must include more than one file"
        last = stop(files[1])
        for file in files[2:N]
            @assert start(file) == last "there is a gap between two adjacent videos: $(start(file) - last)" 
            last = stop(file)
        end
        @assert allunique(getfield.(files, :name)) "all file names must be unique"
        new(files, comment)
    end

end
FragmentedVideo(files::SV, comment::String) where {N, SV <: SVector{N, VideoFile}} = FragmentedVideo{N, SV}(files, comment)

function FragmentedVideo(files::T, comment::String) where {T <: AbstractVector{VideoFile}}
    n = length(files)
    FragmentedVideo(SVector{n, VideoFile}(files), comment)
end


function FragmentedVideo() 
    v1 = VideoFile()
    v2 = VideoFile("__", stop(v1), Millisecond(1))
    FragmentedVideo([v1, v2], "")
end

FragmentedVideo(fv::FragmentedVideo, args) = FragmentedVideo(get(args, :files, fv.files), get(args, :comment, fv.comment))

struct DisjointVideo{N, SV <: SVector{N, VideoFile}} <: AbstractTimeLine
    files::SV
    comment::String

    function DisjointVideo{N, SV}(files, comment) where {N, SV <: SVector{N, VideoFile}}
        n = length(files)
        @assert n > 1 "video collection must include more than one file"
        last = stop(files[1])
        for file in files[2:end]
            @assert start(file) ≥ last "one file starts before the next one ends"
            last = stop(file)
        end
        @assert allunique(getfield.(files, :name)) "all file names must be unique"
        new(SVector{n}(files), comment)
    end

end
DisjointVideo(files::SV, comment::String) where {N, SV <: SVector{N, VideoFile}} = DisjointVideo{N, SV}(files, comment)

function DisjointVideo(files::T, comment::String) where {T <: AbstractVector{VideoFile}}
    n = length(files)
    DisjointVideo(SVector{n, VideoFile}(files), comment)
end

function DisjointVideo() 
    v1 = VideoFile()
    v2 = VideoFile("__", stop(v1) + Millisecond(1), Millisecond(1))
    DisjointVideo([v1, v2], "")
end

DisjointVideo(fv::DisjointVideo, args) = DisjointVideo(get(args, :files, fv.files), get(args, :comment, fv.comment))

AbstractTimeLine(file::VideoFile, comment::String) = WholeVideo(file, comment)
function AbstractTimeLine(files::Vector{VideoFile}, comment::String)
    @assert !isempty(files) "must have some files"
    if length(files) == 1
        WholeVideo(files[], comment)
    else
        if all(stop(prev) == start(next) for (prev, next) in zip(files[1:end-1], files[2:end]))
            FragmentedVideo(files, comment)
        else
            DisjointVideo(files, comment)
        end
    end
end


files(x::AbstractTimeLine) = x.files

filenames(x::AbstractTimeLine) = getfield.(files(x), :name)

start(x::WholeVideo) = start(x.file)
start(x::AbstractTimeLine) = start(first(x.files))
duration(x::WholeVideo) = duration(x.file)
duration(x::FragmentedVideo) = sum(duration, x.files)
duration(x::DisjointVideo) = stop(last(x.files)) - start(first(x.files))


