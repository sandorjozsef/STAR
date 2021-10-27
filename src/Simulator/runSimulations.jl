
include("runSimulationOnPatients.jl")

srcDir = pwd() * "/input/Interesting_Patients_mat"

dstDir = pwd() * "/sim_results/JuliaResults"

egp = 1.16

runSimulationOnPatients(srcDir, dstDir, egp)
