function HISTORIC_controller_simulator(patient, simulation)
  
    if length(patient.Treal) == 1
        println("### HISTORIC_controller_simulator ###")
        patient.nrBg = 1;

        patient.PN = patient.PN_orig
        patient.P = patient.P_orig
        patient.u = patient.u_orig

    else
        patient.nrBg += 1;
    end

    actualBG = patient.Greal[end]
    println("calculating treatments for (nr = ", patient.nrBg, "): ",simulation.t_start + Dates.Minute(round(simulation.t_now)) ,", BG = ", round(actualBG, digits=6), " ...");

    i = findlast(t -> t <= patient.Treal[end], patient.Treal_orig)
    if i < length(patient.Treal_orig)
        simulation.measurement_time = patient.Treal_orig[i+1] - patient.Treal_orig[i]
    else
        simulation.measurement_time = 60.0;
    end

    if patient.Treal[end] >= patient.rawSI[end, 1]
            simulation.stop_simulation = 1;
    end

end