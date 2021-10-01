using Plots

include("ICING2_model_sim_init.jl")
include("ICING2_model_solver.jl")
include("BG_sensor.jl")
include("STAR_controller_simulator.jl")
include("JavaCall\\loadSTARData.jl") 
include("Simulation_Structs.jl")

using .Simulation_Structs


function simulateOnePatientMat(srcPath, dstPath, name, egp)
   
    simulation = Simulation();
    simulation.stop_simulation = 0;
    simulation.measurement_time = 0.0;
    simulation.t_now = 0.0;
    
    patient = Simulation_Structs.Patient();
    guiData = Simulation_Structs.GUIData();
    timeSoln = Simulation_Structs.TimeSoln();
    
    T = Simulation_Structs.TargetRangeData()

    patient.SimulationDate = now();

    
    #loadGUIData(guiData, srcPath * "/" * name * ".GUIData", T);
    #println(guiData.TargetRange)
    #println(guiData.Weight)
    #println(guiData.Age)
    loadPatientData(patient, srcPath * ".mat" );
    
    ICING2_model_sim_init(patient, timeSoln, egp);
    
    #Main simulation loop
    while simulation.stop_simulation == 0

        if simulation.measurement_time > 0
            ICING2_model_solver(patient, timeSoln, simulation.t_now, simulation.t_now + simulation.measurement_time);

            simulation.t_now = simulation.t_now + simulation.measurement_time;

            BG_sensor(patient, timeSoln);
        end
        
        STAR_controller_simulator(patient, simulation);

    end

    return patient;

end