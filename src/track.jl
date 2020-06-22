const Point = SVector{2, Float64}
point(::Missing) = missing
point(x::Instantaneous)= Point(x.data[1], x.data[2])
point(x::Point) = x

mutable struct TimedPoint
    xy::Point
    t::Float64
end

const PointCollection = StructVector{TimedPoint}
pointcollection(x::Missing, t₀) = StructVector{TimedPoint}(undef, 0)
pointcollection(x, t₀) = StructVector(TimedPoint(Point(i[1], i[2]), i[3] - t₀) for i in eachrow(x.data))

mutable struct Track
    coords::Vector{Point}
    t::StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}}
    tp::Int
    rawcoords::StructArray{TimedPoint}
end

function Track(x::Prolonged)
    xyt = !issorted(x.data[:, 3]) ? sortslices(x.data, dims = 1, lt = (x, y) -> isless(x[3], y[3])) : x.data
    raw = pointcollection((data = xyt, ), xyt[1,3])
    Δt = mean(trim(diff(xyt[:, 3]), prop = 0.1))
    n = length(raw.xy)
    tl = range(0.0, step = Δt, length = n)
    spl = ParametricSpline(tl, hcat(raw.xy...); s = 5, k = 2)
    xyl = Point.(spl.(tl))
    Track(xyl, tl, n, raw)
end

homing(t::Track) = t.coords[1:t.tp]
searching(t::Track) = t.coords[t.tp:end]
searchcenter(t::Track) = mean(searching(t))
turningpoint(t::Track) = t.coords[t.tp]

mutable struct Common
    feeder::Union{Missing, Point}
    nest::Union{Missing, Point}
    track::Track
    pellet::PointCollection
    fictive_nest::Point
    pickup::Union{Missing, Point}
    dropoff::Point
end

