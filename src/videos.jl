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

VideoFile() = VideoFile("_", DateTime(1), Nanosecond(1))

VideoFile(vf::VideoFile, args) = VideoFile(get(args, :name, vf.name), get(args, :start, start(vf)), get(args, :duration, duration(vf)))

abstract type AbstractVideo end

struct WholeVideo <: AbstractVideo
    file::VideoFile
    comment::String
end

WholeVideo() = WholeVideo(VideoFile(), "")

WholeVideo(wv::WholeVideo, args) = WholeVideo(get(args, :files, VideoFile(wv.file, args)), get(args, :comment, wv.comment))

files(x::WholeVideo) = [x.file]

struct FragmentedVideo <: AbstractVideo
    files::Vector{VideoFile}
    comment::String

    function FragmentedVideo(files, comment) 
        @assert length(files) > 1 "video collection must include more than one file"
        last = stop(files[1])
        for file in files[2:end]
            @assert start(file) == last "there is a gap between two adjacent videos"
            last = stop(file)
        end
        @assert allunique(getfield.(files, :name)) "all file names must be unique"
        new(files, comment)
    end

end

function FragmentedVideo() 
    v1 = VideoFile()
    v2 = VideoFile("__", stop(v1), Nanosecond(1))
    FragmentedVideo([v1, v2], "")
end

FragmentedVideo(fv::FragmentedVideo, args) = FragmentedVideo(get(args, :files, fv.files), get(args, :comment, fv.comment))

struct DisjointVideo <: AbstractVideo
    files::Vector{VideoFile}
    comment::String

    function DisjointVideo(files, comment) 
        @assert length(files) > 1 "video collection must include more than one file"
        last = stop(files[1])
        for file in files[2:end]
            @assert start(file) ≥ last "one file starts before the next one ends"
            last = stop(file)
        end
        @assert allunique(getfield.(files, :name)) "all file names must be unique"
        new(files, comment)
    end

end

function DisjointVideo() 
    v1 = VideoFile()
    v2 = VideoFile("__", stop(v1) + Nanosecond(1), Nanosecond(1))
    DisjointVideo([v1, v2], "")
end

DisjointVideo(fv::DisjointVideo, args) = DisjointVideo(get(args, :files, fv.files), get(args, :comment, fv.comment))

AbstractVideo(file::VideoFile, comment::String) = WholeVideo(file, comment)
function AbstractVideo(files::Vector{VideoFile}, comment::String)
    if length(files) == 1 
        WholeVideo(files[], comment)
    else
        if foldl((l, r) -> stop(l) == start(r), files)
            FragmentedVideo(files, comment)
        else
            DisjointVideo(files, comment)
        end
    end
end



files(x::AbstractVideo) = x.files

filenames(x::AbstractVideo) = getfield.(files(x), :name)

start(x::WholeVideo) = start(x.file)
start(x::AbstractVideo) = start(first(x.files))
duration(x::WholeVideo) = duration(x.file)
duration(x::FragmentedVideo) = sum(duration, x.files)
duration(x::DisjointVideo) = stop(last(x.files)) - start(first(x.files))


