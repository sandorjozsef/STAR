module Simulation_Structs 

include("$(pwd())\\src\\JavaCall\\JavaClasses.jl")
using Dates

export Patient, Simulation, GUIData, TimeSoln


mutable struct TargetRangeData
    date::DateTime
    targetUpper::Float64
    targetLower::Float64
    TargetRangeData() = new()
end


mutable struct GUIData
    Age::Float64
    Gender::String
    FrameSize::String
    Weight::Float64
    StartTime::DateTime
    DefaultInsulinConc::Float64
    DiabeticStatus::Int32
    TargetRange::Array{TargetRangeData,1}
    J_GuiData::J_GUIData_class
    GUIData() = new()
end

mutable struct Patient
    Treal::Array{Float64,1}
    Greal::Array{Float64,1}
    u::Array{Float64,2}
    P::Array{Float64,2}
    PN::Array{Float64,2}
    Uo::Float64
    Po::Float64
    DiabeticStatus::Int32
    Diabetic::Int32
    rawSI::Array{Float64,2}
    weight::Float64
    guiData::J_GUIData_class
    originalGuiGata::J_GUIData_class
    patient::J_PatientStruct_class
    StochasticModel::J_StochasticModel
    TimeSoln::J_TimeSoln_class
    SimulationDate::DateTime
    ControllerFlag::Array{Float64,1}
    CNS::Float64
    EGP
    Pmax::Float64
    SolverMethod
    Ueninit::Float64
    Vg::Float64
    Vi::Float64
    alpha_G::Float64
    alpha_I::Float64
    d1::Float64
    d2::Float64
    gamma::Float64
    k1
    k2
    nC::Float64
    nI::Float64
    nK::Float64
    nL::Float64
    pG::Float64
    stochasticModelFileName
    uenmax::Float64
    uenmin::Float64
    varEGP
    xl::Float64
    u_orig
    P_orig
    PN_orig
    Treal_orig::Array{Float64,1}
    Greal_orig::Array{Float64,1}
    P_prior
    GoalFeed::Float64
    StoppedFeed
    nrBg
    RestartRate
    Patient() = new()
end

mutable struct TimeSoln
    T::Array{Float64,1}
    GIQ::Array{Float64,2}
    P::Array{Float64,2}
    TimeSoln() = new()
end


mutable struct Simulation
    stop_simulation 
    measurement_time
    t_now::Float64
    t_start::DateTime
    longest_allowed::Int64
    mode::Int64
    nutrition_dosing::Int64
    protocol_timing::Int64
    Simulation() = new()
end


end