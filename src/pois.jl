struct POI{T, U}
    calib::T # Calibration -> name for the matlab calibration file or maybe the transformation matrix itself
    data::U # Temporal -> pixel coordinates
end

POI{T, U}() where {T, U} = POI(T(), U())

# struct POI{V <: AbstractTimeLine, T <: AbstractPeriod}
#     calib::Dict{UUID, <:Calibration}
#     temporal::Temporal{V, T}
#     spatial::UUID
# end
