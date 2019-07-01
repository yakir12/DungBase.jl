struct Board
    designation::String
    checker_width_cm::Float64
    dimensions::Tuple{Int, Int}
    description::String

    function Board(designation, checker_width_cm, dimensions, description)
        @assert checker_width_cm > 0 "checker width must be larger zero"
        w, h = dimensions
        @assert w > 1 "number of checkers must be larger one"
        @assert h > 1 "number of checkers must be larger one"
        new(designation, checker_width_cm, dimensions, description)
    end

end

struct Calibration{T, S}
    intrinsic::T # Missing or Temporal{Prolonged}
    extrinsic::S # Temporal{Instantaneous}
    board::Board
    comment::String
end

