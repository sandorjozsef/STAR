include("JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientMat.jl")
include("Statistics\\Statistics.jl")
include("Statistics\\Serializer.jl")
using Dates
using .Statistics
using .Serializer

    function runSimulationOnPatients(srcDir, dstDir, egp)

        simFolderOut = joinpath(dstDir , "Simresults-" * 
            string(today()) *"_"* string(hour(now())) *"_"* string(minute(now())));
        
        if ispath(simFolderOut) == false
            mkdir(simFolderOut)
            #mkdir(joinpath(simFolderOut, "patientsBG"))
        end

        setup_java_libraries()

        allHourlyBG = []

        for name in readdir(srcDir)
            srcPath = joinpath(srcDir, name);
            println("\nProcess patient: ", name);
           
            @time patient = simulateOnePatientMat(srcPath, simFolderOut, name, egp)

            serPatient = SerializablePatient()
            serPatient.Greal = patient.Greal
            serPatient.Treal = patient.Treal
            serialize(serPatient, "$simFolderOut\\$name.jld2")

            allHourlyBG = cat(allHourlyBG, patient.hourlyBG, dims = 1)
        end
        

        #writeCSV_ResampledBGStats(allHourlyBG, simFolderOut * "/statistics_hourly_resampled_BG.csv")
        #plotCDF(allHourlyBG, simFolderOut)
    
        calculate_signDiff_Jul2Mat(simFolderOut)

    end


