include("ICING2_model_sim_init.jl")
include("ICING2_model_solver.jl")
include("BG_sensor.jl")
include("STAR_controller_simulator.jl")
include("Simulation_Structs.jl")
include("SIMPLE_controller_simulator.jl")
include("Statistics//Serializer.jl")

using .Simulation_Structs
using .Serializer

function simulateOnePatientJul(srcPath, dstPath, name, egp)
   
    simulation = Simulation();
    simulation.stop_simulation = 0;
    simulation.measurement_time = 0.0;
    simulation.t_now = 0.0;
    simulation.t_start = now();

    # longest allowed treatment: 1 / 2 / 3
    simulation.longest_allowed = 3;

    # 1 -> STAR recommended
    # 2 -> SIMPLE
    simulation.mode = 1 ; 

    # 1 -> low nutrition 
    # 2 -> normal nutrition 
    # 3 -> high nutrition
    simulation.NutritionDispenser = 2;

    # 1 -> exact STAR
    # 2 -> original historic
    simulation.measuring_type = 1 ;
    
    patient = Simulation_Structs.Patient();
    patient.SimulationDate = now();
    
    serPatient = Serializer.deserialize(srcPath, name)
    patient.Treal_orig = serPatient.Treal
    patient.Greal_orig = serPatient.Greal
    patient.u = serPatient.u
    patient.P = serPatient.P
    patient.PN  = serPatient.PN
    patient.Uo = serPatient.Uo 
    patient.Po = serPatient.Po 
    patient.rawSI = serPatient.rawSI
    patient.GoalFeed = serPatient.GoalFeed
  

    timeSoln = Simulation_Structs.TimeSoln();
    
    ICING2_model_sim_init(patient, timeSoln, egp);
    
    #Main simulation loop
    while simulation.stop_simulation == 0

        if simulation.measurement_time > 0
            ICING2_model_solver(patient, timeSoln, simulation.t_now, simulation.t_now + simulation.measurement_time);

            simulation.t_now = simulation.t_now + simulation.measurement_time;

            BG_sensor(patient, timeSoln);
        end

        if simulation.mode == 1  STAR_controller_simulator(patient, simulation); end
        if simulation.mode == 2  SIMPLE_controller_simulator(patient, simulation); end
       
    end

    return (patient,  timeSoln);

end