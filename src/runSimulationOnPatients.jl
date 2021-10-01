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
            patientname = splitext(name)[1]
            srcPath = joinpath(srcDir, patientname);
            println("\nProcess patient: ", patientname);
            @time patient = simulateOnePatientMat(srcPath, simFolderOut, patientname, egp)

            serPatient = Serializer.SerializablePatient()
            serPatient.Greal = patient.Greal
            serPatient.Treal = patient.Treal
            serPatient.hourlyBG = patient.hourlyBG
            serPatient.Name = patientname
            Serializer.serialize(serPatient, "$simFolderOut\\$patientname.jld2")

        end
        
  
    end


