module Julia_Statistics

    include("Serializer.jl")
    include("Visualizer.jl")
    include("StatisticsExporter.jl")
    using .Serializer
    using .Visualizer
    using Statistics
    using .StatisticsExporter

    srcpath1 = "D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\JuliaResults\\Tsit5_1e_6"
    srcpath2 = "D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\JuliaResults\\DP5_1e_6"
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

    export calculate_signDiffBG_Mat2Jul
    function calculate_signDiffBG_Mat2Jul()

        signDiffBG_all = []
        maxi = 0.0
        mini = 0.0
        maxName = ""
        minName = ""
        cnt = 0

        for filename in readdir(srcpath)

            JuliaPatient = Serializer.deserialize(joinpath(srcpath, filename))
            
            patientName = splitext(filename)[1]
            matlabPath = "$(pwd())\\src\\Statistics\\MatLabResults\\SIM_$patientName.mat"  
            MatlabPatient = Serializer.deserializeMat(matlabPath) 
            
            signDiffBG = []
            len = min(length(MatlabPatient.Greal), length(JuliaPatient.Greal))
            for i in 1:len
                if MatlabPatient.Treal[i] == JuliaPatient.Treal[i]
                    push!(signDiffBG, MatlabPatient.Greal[i]-JuliaPatient.Greal[i])
                else
                    cnt = cnt+1
                end
            end

            if minimum(signDiffBG) < mini
                mini = minimum(signDiffBG)
                minName = JuliaPatient.Name
            end

            if maximum(signDiffBG) > maxi
                maxi = maximum(signDiffBG)
                maxName = JuliaPatient.Name
            end

            signDiffBG_all = cat(signDiffBG_all, signDiffBG, dims=1)
            Visualizer.plot_Mat_Jul_patient(MatlabPatient, JuliaPatient)
           
        end

        Visualizer.plot_histogram(signDiffBG_all)
        

        println("max diff: ", maximum(signDiffBG_all), " -- ", maxName)
        println("min diff: ", minimum(signDiffBG_all), " -- ", minName)
        println("mean diff: ", Statistics.mean(signDiffBG_all))
        println("std diff: ", Statistics.std(signDiffBG_all))
        println(cnt," + ", length(signDiffBG_all))
       
    end

    function calculate_signDiffBG_Jul2Jul()
        signDiffBG_all = []
        maxi = 0.0
        mini = 0.0
        maxName = ""
        minName = ""
        cnt = 0

        for filename in readdir(srcpath1)

            JuliaPatient1 = Serializer.deserialize(joinpath(srcpath1, filename))
            JuliaPatient2 = Serializer.deserialize(joinpath(srcpath2, filename))
            
            signDiffBG = []
            len = min(length(JuliaPatient1.Greal), length(JuliaPatient2.Greal))
            for i in 1:len
                if JuliaPatient1.Treal[i] == JuliaPatient2.Treal[i]
                    push!(signDiffBG, JuliaPatient1.Greal[i]-JuliaPatient2.Greal[i])
                else
                    cnt = cnt+1
                end
            end

            if minimum(signDiffBG) < mini
                mini = minimum(signDiffBG)
                minName = JuliaPatient1.Name
            end

            if maximum(signDiffBG) > maxi
                maxi = maximum(signDiffBG)
                maxName = JuliaPatient1.Name
            end

            signDiffBG_all = cat(signDiffBG_all, signDiffBG, dims=1)
            Visualizer.plot_Mat_Jul_patient(JuliaPatient1, JuliaPatient2)
           
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

    calculate_signDiffBG_Jul2Jul()
    #calculate_signDiffBG_Mat2Jul() 
    #createJuliaStatistics()
    #printData(srcpath)
    
    

end