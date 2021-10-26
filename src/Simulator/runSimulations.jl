#import Pkg
#Pkg.add("Plots")
#Pkg.add("OrdinaryDiffEq")
#Pkg.add("CSV")
#Pkg.add("DataFrames")
#Pkg.add("Statistics")
#Pkg.add("JavaCall")
#Pkg.add("JLD2")
#Pkg.add("MAT")
#Pkg.add("FileIO")  
#Pkg.add("Pipe")

include("runSimulationOnPatients.jl")

srcDir = pwd() * "/input/Interesting_Patients_mat"

dstDir = pwd() * "/sim_results/JuliaResults"

egp = 1.16

runSimulationOnPatients(srcDir, dstDir, egp)
