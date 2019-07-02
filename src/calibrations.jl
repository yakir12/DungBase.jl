struct Board
    designation::String
    checker_width_cm::Float64
    dimensions::Tuple{Int, Int}
    description::String

    function Board(designation, checker_width_cm, dimensions, description)
        @assert !isempty(designation) "empty board designation is not allowed"
        @assert checker_width_cm > 0 "checker width must be larger zero"
        w, h = dimensions
        @assert w > 1 "number of checkers must be larger one"
        @assert h > 1 "number of checkers must be larger one"
        @assert !isempty(description) "empty board description is not allowed"
        new(designation, checker_width_cm, dimensions, description)
    end

end

Board() = Board("_", 1.0, (2,2), "_")

struct Calibration{T, S}
    intrinsic::T # Missing or Temporal{Prolonged}
    extrinsic::S # Temporal{Instantaneous}
    board::Board
    comment::String
end

Calibration() = Calibration(missing, Temporal(), Board(), "")

filenames(c::Calibration) = first(filenames(c.extrinsic.video))
start(c::Calibration) = start(c.extrinsic.time)
