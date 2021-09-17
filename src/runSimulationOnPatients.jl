include("JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientMat.jl")
include("Statistics\\Statistics.jl")
using Dates
using .Statistics
using JLD2
using FileIO

    function runSimulationOnPatients(srcDir, dstDir, egp)

        simFolderOut = joinpath(dstDir , "Simresults-" * 
            string(today()) *"_"* string(hour(now())) *"_"* string(minute(now())));
        
        if ispath(simFolderOut) == false
            mkdir(simFolderOut)
            #mkdir(joinpath(simFolderOut, "patientsBG"))
        end

        setup_java_libraries()

       

        allHourlyBG = []

        for (root, dirs) in walkdir(srcDir)
            for name in dirs
                srcPath = joinpath(root, name);
                println("\nProcess patient: ", name);
                @time patient = simulateOnePatientMat(srcPath, simFolderOut, name, egp)

                serPatient = SerializablePatient()
                serPatient.Greal = patient.Greal
                serPatient.T = 5.9

                save("$simFolderOut\\$name.jld2", Dict("Greal" => serPatient.Greal, "T" => serPatient.T))
                
                allHourlyBG = cat(allHourlyBG, patient.hourlyBG, dims = 1)
            end
        end

    #writeCSV_ResampledBGStats(allHourlyBG, simFolderOut * "/statistics_hourly_resampled_BG.csv")

    #plotCDF(allHourlyBG, simFolderOut)
    calculate_signDiff_Jul2Mat()

    end


