module Julia_Statistics

    include("Serializer.jl")
    include("Visualizer.jl")
    include("StatisticsExporter.jl")
    using .Serializer
    using .Visualizer
    using Statistics
    using .StatisticsExporter


    RawBG = Vector{Vector{Float64}}()
    HourlyBG = Vector{Vector{Float64}}()
    allHourlyBG = Vector{Float64}()
    allRawBG = Vector{Float64}()

    function createDataStructures(srcpath, type)

        for filename in readdir(srcpath)

            patientName = splitext(filename)[1]
            JuliaPatient = Serializer.deserialize(srcpath, patientName, type)
            for i in 1:length(JuliaPatient.GIQ[:,1])
                push!(allRawBG, JuliaPatient.GIQ[i,1])
            end
            for i in 1:length(JuliaPatient.hourlyBG)
                push!(allHourlyBG, JuliaPatient.hourlyBG[i])
            end
            push!(RawBG, JuliaPatient.GIQ[:,1])
            push!(HourlyBG, JuliaPatient.hourlyBG)

        end

    end

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
            len = min(length(Patient1.GIQ[:,1]), length(Patient2.GIQ[:,1]))
            for i in 1:len
                if Patient1.Treal[i] == Patient2.Treal[i]
                    push!(signDiffBG, Patient1.GIQ[i,1]-Patient2.GIQ[i,1])
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
            Visualizer.plot_patient_metabolics(Patient1)
            Visualizer.plot_patient_metabolics(Patient2)
           
        end

        Visualizer.plot_histogram(signDiffBG_all)
        
        println("max diff: ", maximum(signDiffBG_all), " -- ", maxName)
        println("min diff: ", minimum(signDiffBG_all), " -- ", minName)
        println("mean diff: ", Statistics.mean(signDiffBG_all))
        println("std diff: ", Statistics.std(signDiffBG_all))
        println(cnt," + ", length(signDiffBG_all))
       
    end



    function createStatistics(srcpath, type)

        createDataStructures(srcpath, type)
        StatisticsExporter.wholeCohortStats(RawBG, HourlyBG, dstpath)
        StatisticsExporter.rawBGStats(allRawBG, RawBG, dstpath)
        StatisticsExporter.hourlyResampledBGStats(allHourlyBG, dstpath)
        StatisticsExporter.perEpisode_statistics(dstpath)

    end

    julpath1 = "$(pwd())\\src\\Statistics\\JuliaResults\\Tsit5_1e_6"
    julpath2 = "$(pwd())\\src\\Statistics\\JuliaResults\\Tsit5_1e_8"
    julpath3 = "$(pwd())\\src\\Statistics\\JuliaResults\\DP5_1e_6"
    julpath4 = "$(pwd())\\src\\Statistics\\JuliaResults\\DP5_1e_8"

    matpath1 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_6"
    matpath2 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_8"
    matpath3 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_12"

    dstpath = "$(pwd())\\src\\Statistics\\Julia_Statistics\\res2.csv"

    calculate_signDiffBG(julpath1, julpath2, "JUL", "JUL")
    #calculate_signDiffBG(julpath1, julpath3, "JUL", "JUL")
    #calculate_signDiffBG(julpath2, julpath4, "JUL", "JUL")
 
    #calculate_signDiffBG(julpath3, matpath1, "JUL", "MAT") 
    #calculate_signDiffBG(julpath2, matpath2, "JUL", "MAT")
    #calculate_signDiffBG(julpath5, matpath3, "JUL", "MAT")
    #calculate_signDiffBG(matpath1, matpath3, "MAT", "MAT")
    #createStatistics(julpath5, "JUL")
    #createStatistics(matpath1, "MAT")


      

    
end