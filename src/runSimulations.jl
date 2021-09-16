#import Pkg
#Pkg.add("Plots")
#Pkg.add("OrdinaryDiffEq")
#Pkg.add("CSV")
#Pkg.add("DataFrames")
#Pkg.add("Statistics")
#Pkg.add("JavaCall")

include("runSimulationOnPatients.jl")

srcDir = pwd() * "/src/HU"
dstDir = pwd() * "/src/Results"

egp = 1.16

runSimulationOnPatients(srcDir, dstDir, egp)