mutable struct SimulatorGUIInfo
    srcDir::String
    dstDir::String
    mode::Int
    longest_allowed::Int
    protocol_timing::Int
    nutrition_dosing::Int
    SimulatorGUIInfo() = new()
end