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

include("runSimulationOnPatients.jl")

srcDir = pwd() * "/src/HU"
dstDir = pwd() * "/src/Statistics/JuliaResults"

egp = 1.16

runSimulationOnPatients(srcDir, dstDir, egp)
