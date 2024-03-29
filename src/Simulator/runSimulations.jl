include("runSimulationOnPatients.jl")
using ThreadPools

function runSimulations()
    
srcDir = pwd() * "/patients_data/original/interesting_patients_mat"
baseDir = pwd() * "/patients_data/simulated"
if ispath(baseDir) == false 
    mkdir(baseDir)
end

dstDir = pwd() * "/patients_data/simulated/julia_results"
if ispath(dstDir) == false 
    mkdir(dstDir)
end

simulation = Simulation()

    # 1 -> STAR recommended
    # 2 -> SIMPLE
    # 3 -> HISTORIC
simulation.mode = 1 ; 

    # Only for STAR and SIMPLE
    # longest allowed treatment: 1 / 2 / 3
simulation.longest_allowed = 3 ;

    # Only for STAR and SIMPLE (HISTORIC is always historic)
    # 1 -> exact longest allowed
    # 2 -> historic
simulation.protocol_timing = 2 ;

    # Only for SIMPLE controller
    # 1 -> low nutrition 
    # 2 -> normal nutrition k
    # 3 -> high nutrition
simulation.nutrition_dosing = 2;

runSimulationOnPatients(srcDir, dstDir, simulation)

end

runSimulations()




