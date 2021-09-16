using Dates

include("JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientMat.jl")
    
function runSimulationOnPatients(srcDir, dstDir, egp)

    simFolderOut = joinpath(dstDir , "Simresults-" * 
        string(today()) *"_"* string(hour(now())) *"_"* string(minute(now())));
    
    if ispath(simFolderOut) == false
        mkdir(simFolderOut)
        mkdir(joinpath(simFolderOut, "patientsBG"))
    end

    setup_java_libraries()

    #Statistics_STAR = Statistics_STAR()

    allHourlyBG = []

    for (root, dirs) in walkdir(srcDir)
        for name in dirs
            srcPath = joinpath(root, name);
            println("\nProcess patient: ", name);
            @time patient = simulateOnePatientMat(srcPath, simFolderOut, name, egp)
            allHourlyBG = cat(allHourlyBG, patient.hourlyBG, dims = 1)
        end
    end

   #writeCSV_ResampledBGStats(allHourlyBG, simFolderOut * "/statistics_hourly_resampled_BG.csv")

   #plotCDF(allHourlyBG, simFolderOut)

end
