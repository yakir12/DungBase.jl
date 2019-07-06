struct POI{V <: AbstractVideo}
    calib::Vector{Calibration}
    temporal::Temporal{V}
    spatial::UUID
end


