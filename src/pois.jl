struct POI{V <: AbstractTimeLine, T <: AbstractPeriod}
    calib::Calibration
    temporal::Temporal{V, T}
end


