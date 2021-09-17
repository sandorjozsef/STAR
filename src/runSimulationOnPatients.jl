include("JavaCall\\setup_java_libraries.jl")
include("simulateOnePatientMat.jl")
include("Statistics\\Statistics.jl")
using Dates
using JLD
using .Statistics

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

                push!(LOAD_PATH, pwd() * "\\src")
                jldopen("$simFolderOut\\$name.jld", "w") do file
                    addrequire(file, :Statistics)
                    write(file, "serPatient", serPatient)
                end

                #=
                c = jldopen("$simFolderOut\\$name.jld", "r") do file
                    read(file, "serPatient")
                end 
                println(c.Greal)
                =#
                pop!(LOAD_PATH)


                allHourlyBG = cat(allHourlyBG, patient.hourlyBG, dims = 1)
            end
        end

    #writeCSV_ResampledBGStats(allHourlyBG, simFolderOut * "/statistics_hourly_resampled_BG.csv")

    #plotCDF(allHourlyBG, simFolderOut)

    end


