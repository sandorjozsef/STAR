module Julia_Statistics

    include("Serializer.jl")
    include("Visualizer.jl")
    include("StatisticsExporter.jl")
    using .Serializer
    using .Visualizer
    using Statistics
    using .StatisticsExporter

    julpath1 = "D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\JuliaResults\\Tsit5_1e_6"
    julpath2 = "D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\JuliaResults\\DP5_1e_6"
    matpath1 = "$(pwd())\\src\\Statistics\\MatLabResults"
    matpath2 = ""
    dstpath = "D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\Julia_Statistics\\res2.csv"

    RawBG = Vector{Vector{Float64}}()
    HourlyBG = Vector{Vector{Float64}}()
    allHourlyBG = Vector{Float64}()
    allRawBG = Vector{Float64}()

    function createDataStructures()

        for filename in readdir(srcpath)

            JuliaPatient = Serializer.deserialize(joinpath(srcpath, filename))
            for i in 1:length(JuliaPatient.Greal)
                push!(allRawBG, JuliaPatient.Greal[i])
            end
            for i in 1:length(JuliaPatient.hourlyBG)
                push!(allHourlyBG, JuliaPatient.hourlyBG[i])
            end
            push!(RawBG, JuliaPatient.Greal)
            push!(HourlyBG, JuliaPatient.hourlyBG)

        end

    end

    export calculate_signDiffBG
    function calculate_signDiffBG(srcpath1, srcpath2, type1, type2)

        signDiffBG_all = []
        maxi = 0.0
        mini = 0.0
        maxName = ""
        minName = ""
        cnt = 0

        for filename in readdir(srcpath1)

            patientName = splitext(filename)[1]

            Patient1 = Serializer.deserialize(srcpath1, patientName, type1)
            Patient2 = Serializer.deserialize(srcpath2, patientName, type2)
           
            signDiffBG = []
            len = min(length(Patient1.Greal), length(Patient2.Greal))
            for i in 1:len
                if Patient1.Treal[i] == Patient2.Treal[i]
                    push!(signDiffBG, Patient1.Greal[i]-Patient2.Greal[i])
                else
                    cnt = cnt+1
                end
            end

            if minimum(signDiffBG) < mini
                mini = minimum(signDiffBG)
                minName = Patient1.Name
            end

            if maximum(signDiffBG) > maxi
                maxi = maximum(signDiffBG)
                maxName = Patient1.Name
            end

            signDiffBG_all = cat(signDiffBG_all, signDiffBG, dims=1)
            Visualizer.plot_patient_BG(Patient1, Patient2)
           
        end

        Visualizer.plot_histogram(signDiffBG_all)
        

        println("max diff: ", maximum(signDiffBG_all), " -- ", maxName)
        println("min diff: ", minimum(signDiffBG_all), " -- ", minName)
        println("mean diff: ", Statistics.mean(signDiffBG_all))
        println("std diff: ", Statistics.std(signDiffBG_all))
        println(cnt," + ", length(signDiffBG_all))
       
    end


    function printData(path)

        for filename in readdir(path)

            JuliaPatient = Serializer.deserialize(joinpath(path, filename))
            display(JuliaPatient.Name)
            display(JuliaPatient.Greal)
            display(JuliaPatient.hourlyBG)

        end
    end

    function createJuliaStatistics()

        createDataStructures()
        StatisticsExporter.writeCSV_WholeCohortStats(RawBG, HourlyBG, dstpath)
        StatisticsExporter.writeCSV_HourlyResampledBGStats(allHourlyBG, dstpath)
        StatisticsExporter.writeCSV_RawBGStats(allRawBG, RawBG, dstpath)

    end

    calculate_signDiffBG(julpath1, julpath2, "JUL", "JUL") 
    #createJuliaStatistics()
    #printData(srcpath)
    
    
end