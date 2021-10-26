include("$(pwd())\\src\\JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientJul.jl")
include("$(pwd())\\src\\Statistics\\Serializer.jl")
using Dates
using .Serializer

    function runSimulationOnPatients(srcDir, dstDir, egp)

        simFolderOut = joinpath(dstDir , "Simresults-" * 
            string(today()) *"_"* string(hour(now())) *"_"* string(minute(now())));
        
        if ispath(simFolderOut) == false
            mkdir(simFolderOut)
        end

        setup_java_libraries()

        for name in readdir(srcDir)
            patientname = splitext(name)[1]
            println("\nProcess patient: ", patientname);
            @time (patient, timeSoln) = simulateOnePatientJul(srcDir, simFolderOut, patientname, egp)

            serPatient = Serializer.SerializablePatient()
            serPatient.TimeSolnGIQ = timeSoln.GIQ
            serPatient.TimeSolnT = timeSoln.T
            serPatient.Treal = patient.Treal
            serPatient.Greal = patient.Greal
            serPatient.P = patient.P
            serPatient.PN = patient.PN
            serPatient.rawSI = patient.rawSI
            serPatient.hourlyBG = patient.hourlyBG
            serPatient.u = patient.u
            serPatient.Name = patientname
            serPatient.GoalFeed = patient.GoalFeed
            serPatient.Uo = patient.Uo
            serPatient.Po = patient.Po
            serPatient.Treal_orig = patient.Treal_orig
            serPatient.Greal_orig = patient.Greal_orig
            Serializer.serialize(serPatient, "$simFolderOut\\$patientname.jld2")

        end
        
    end


