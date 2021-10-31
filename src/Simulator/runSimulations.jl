
include("runSimulationOnPatients.jl")

srcDir = pwd() * "/input/Interesting_Patients_mat"

dstDir = pwd() * "/sim_results/JuliaResults"

if ispath(dstDir) == false
    mkdir(dstDir)
end

runSimulationOnPatients(srcDir, dstDir)
