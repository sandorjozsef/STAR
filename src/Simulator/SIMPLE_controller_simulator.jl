include("$(pwd())\\src\\Logger.jl")
using .Logger

function SIMPLE_controller_simulator(patient, simulation)
  
    if length(patient.Treal) == 1
        patient.nrBg = 1;

        log = "### SIMPLE_controller_simulator ###"
        println(log)
        Logger.log(log)

    else
        patient.nrBg += 1;
    end

    actualBG = patient.Greal[end]
    log = "calculating treatments for (nr = $(patient.nrBg)) : $(simulation.t_start + Dates.Minute(round(simulation.t_now))), BG = $(round(actualBG, digits=6)) "
    println(log);
    Logger.log(log)

    selection = simulation.longest_allowed
    
    unit = 100.0 / 6.0 # mUnit/min
    nrOfUnits = 0
    if (actualBG > 6 && actualBG <= 8) nrOfUnits = 1 end
    if (actualBG > 8 && actualBG <= 10) nrOfUnits = 2 end
    if (actualBG > 10 && actualBG <= 12) nrOfUnits = 3 end
    if (actualBG > 12 && actualBG <= 14) nrOfUnits = 4 end
    if (actualBG > 14 && actualBG <= 16) nrOfUnits = 5 end
    if (actualBG > 16) nrOfUnits = 6 end
    patient.u = [patient.u; patient.u[end,1]+selection*60-1 nrOfUnits * unit]
    patient.u = [patient.u; patient.u[end,1]+1 nrOfUnits * unit]

    Nutr = 0.0
    if simulation.nutrition_dosing == 1 Nutr=0.25 end
    if simulation.nutrition_dosing == 2 Nutr=0.4 end
    if simulation.nutrition_dosing == 3 Nutr=0.6 end
    patient.P = [patient.P; patient.P[end,1]+selection*60 Nutr]
        
    patient.PN = [patient.PN; patient.PN[end,1]+selection*60-5 0.0] #parenteral = 0
    patient.PN = [patient.PN; patient.PN[end,1]+5 0.0]

    if simulation.protocol_timing == 1
        simulation.measurement_time = selection * 60.0;
    end

    if simulation.protocol_timing == 2
        i = findlast(t -> t <= patient.Treal[end], patient.Treal_orig)
        if i < length(patient.Treal_orig)
            simulation.measurement_time = patient.Treal_orig[i+1] - patient.Treal_orig[i]
        else
            simulation.measurement_time = 60.0;
        end
    end

    if patient.Treal[end] >= patient.rawSI[end, 1]
            simulation.stop_simulation = 1;
    end

end