include("JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientMat.jl")
include("Statistics\\Julia_Statistics.jl")
include("Statistics\\Serializer.jl")
using Dates
using .Julia_Statistics
using .Serializer

    function runSimulationOnPatients(srcDir, dstDir, egp)

        simFolderOut = joinpath(dstDir , "Simresults-" * 
            string(today()) *"_"* string(hour(now())) *"_"* string(minute(now())));
        
        if ispath(simFolderOut) == false
            mkdir(simFolderOut)
            #mkdir(joinpath(simFolderOut, "patientsBG"))
        end

        setup_java_libraries()

        for name in readdir(srcDir)
            srcPath = joinpath(srcDir, name);
            println("\nProcess patient: ", name);
            @time patient = simulateOnePatientMat(srcPath, simFolderOut, name, egp)

            serPatient = Serializer.SerializablePatient()
            serPatient.Greal = patient.Greal
            serPatient.Treal = patient.Treal
            serPatient.hourlyBG = patient.hourlyBG
            serPatient.Name = name
            Serializer.serialize(serPatient, "$simFolderOut\\$name.jld2")

        end
        
  
    end


