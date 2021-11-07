include("$(pwd())\\src\\JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientJul.jl")
include("$(pwd())\\src\\Statistics\\Serializer.jl")
using Dates
using .Serializer

    function runSimulationOnPatients(srcDir, dstDir, simulation)

        simFolderOut = joinpath(dstDir , "Simresults-" * 
            string(today()) *"_"* string(hour(now())) *"_"* string(minute(now())));
        
        if ispath(simFolderOut) == false
            mkdir(simFolderOut)
        end

        # if STAR is the actual controller
        if simulation.mode == 1
            setup_java_libraries()
        end

        for name in readdir(srcDir)
            patientname = splitext(name)[1]
            println("\nProcess patient: ", patientname);
            @time (patient, timeSoln) = simulateOnePatientJul(srcDir, patientname, simulation)

            serPatient = Serializer.SerializablePatient()
            serPatient.TimeSolnGIQ = timeSoln.GIQ
            serPatient.TimeSolnT = timeSoln.T
            serPatient.Treal = patient.Treal
            serPatient.Greal = patient.Greal
            serPatient.P = patient.P
            serPatient.PN = patient.PN
            serPatient.rawSI = patient.rawSI
            serPatient.u = patient.u
            serPatient.Name = patientname
            serPatient.GoalFeed = patient.GoalFeed
            serPatient.Uo = patient.Uo
            serPatient.Po = patient.Po
            serPatient.Treal_orig = patient.Treal_orig
            serPatient.Greal_orig = patient.Greal_orig
            serPatient.hourlyBG = []
            Serializer.serialize(serPatient, "$simFolderOut\\$patientname.jld2")

        end
        
    end


