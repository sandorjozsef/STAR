using Plots

include("ICING2_model_sim_init.jl")
include("ICING2_model_solver.jl")
include("BG_sensor.jl")
include("STAR_controller_simulator.jl")
include("JavaCall\\loadSTARData.jl")
#include("statisticsHelper.jl")
include("Simulation_Structs.jl")

using .Simulation_Structs

function simulateOnePatientMat(srcPath, dstPath, name, egp)
   
    simulation = Simulation();
    simulation.stop_simulation = 0;
    simulation.measurement_time = 0.0;
    simulation.t_now = 0.0;
    
    patient = Patient();
    guiData = GUIData();
    timeSoln = TimeSoln();

    patient.SimulationDate = now();

    
    #loadGUIData(guiData, srcPath * "/" * name * ".GUIData");
    loadPatientData(patient, srcPath * "/" * name * ".PatientStruct");

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

    #printPatientData(patient);
    #printGUIData(guiData);
    #plotPatientBG(patient, dstPath * "/patientsBG/"  * name * ".png");

    return patient;

end