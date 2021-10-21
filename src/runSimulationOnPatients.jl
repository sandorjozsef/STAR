include("JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientJul.jl")
include("Statistics\\Serializer.jl")
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
            srcPath = joinpath(srcDir, patientname);
            println("\nProcess patient: ", patientname);
            @time patient = simulateOnePatientJul(srcPath, simFolderOut, patientname, egp)

            serPatient = Serializer.SerializablePatient()
            serPatient.GIQ = [patient.Greal patient.Ireal patient.Qreal]
            serPatient.Treal = patient.Treal
            serPatient.P = patient.P
            serPatient.PN = patient.PN
            serPatient.rawSI = patient.rawSI
            serPatient.hourlyBG = patient.hourlyBG
            serPatient.u = patient.u
            serPatient.Name = patientname
            serPatient.GoalFeed = patient.GoalFeed
            Serializer.serialize(serPatient, "$simFolderOut\\$patientname.jld2")

        end
        
    end


