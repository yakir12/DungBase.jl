struct POI{V <: AbstractTimeLine, T <: AbstractPeriod}
    calib::Vector{Calibration}
    temporal::Temporal{V, T}
    spatial::UUID
end


