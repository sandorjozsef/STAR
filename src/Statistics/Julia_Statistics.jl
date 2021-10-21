module Julia_Statistics

    include("Serializer.jl")
    include("Visualizer.jl")
    include("StatisticsExporter.jl")
    using .Serializer
    using .Visualizer
    using Statistics
    using .StatisticsExporter


    RawBG = Vector{Vector{Float64}}()
    Treal = Vector{Vector{Float64}}()
    u = Vector{Matrix{Float64}}()
    P = Vector{Matrix{Float64}}()
    PN = Vector{Matrix{Float64}}()
    HourlyBG = Vector{Vector{Float64}}()
    GoalFeeds = Vector{Float64}()

    function createDataStructures(srcpath)

        for filename in readdir(srcpath)

            patientName = splitext(filename)[1]
            JuliaPatient = Serializer.deserialize(srcpath, patientName)
            
            push!(Treal, JuliaPatient.Treal)
            push!(RawBG, JuliaPatient.GIQ[:,1])
            push!(HourlyBG, JuliaPatient.hourlyBG)
            push!(u, JuliaPatient.u)
            push!(P, JuliaPatient.P) 
            push!(PN, JuliaPatient.PN)
            push!(GoalFeeds, JuliaPatient.GoalFeed)
        end

    end

    function calculate_signDiffBG(srcpath1, srcpath2)

        signDiffBG_all = []
        maxi = 0.0
        mini = 0.0
        maxName = ""
        minName = ""
        cnt = 0
        srcpath = srcpath1
        if length(readdir(srcpath1)) > length(readdir(srcpath2)) 
            srcpath = srcpath2
        end
        for filename in readdir(srcpath)

            patientName = splitext(filename)[1]

            Patient1 = Serializer.deserialize(srcpath1, patientName)
            Patient2 = Serializer.deserialize(srcpath2, patientName)
           
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

            Visualizer.plot_compare_patient_metabolics(Patient1, Patient2)
            #Visualizer.plot_patient_BG(Patient1, Patient2)
           
        end

        #Visualizer.plot_histogram(signDiffBG_all)
        
        println("max diff: ", maximum(signDiffBG_all), " -- ", maxName)
        println("min diff: ", minimum(signDiffBG_all), " -- ", minName)
        println("mean diff: ", Statistics.mean(signDiffBG_all))
        println("std diff: ", Statistics.std(signDiffBG_all))
        println(cnt," + ", length(signDiffBG_all))
       
    end

    function plot_simulation(srcpath1)

        for filename in readdir(srcpath1)
            patientName = splitext(filename)[1]
            Patient1 = Serializer.deserialize(srcpath1, patientName)
            Visualizer.plot_patient_metabolics(Patient1) 
        end

    end

    function createStatistics(srcpath, dstpath)

        createDataStructures(srcpath)
        StatisticsExporter.wholeCohortStats(RawBG, HourlyBG, dstpath)
        StatisticsExporter.rawBGStats(RawBG, dstpath)
        StatisticsExporter.hourlyResampledBGStats(HourlyBG, dstpath)
        StatisticsExporter.perEpisode_statistics(RawBG, Treal, dstpath)
        StatisticsExporter.intervention_cohort_stats_hourlyAverage(u, P, PN, GoalFeeds, dstpath)
        StatisticsExporter.intervention_perEpisode_stats_hourlyAverage(u, P, PN, GoalFeeds, dstpath)


    end

    # (longest allowed - insulin dosing - nutrition dosing)
    julpath1 = "$(pwd())\\src\\Statistics\\JuliaResults\\3hour_STAR"
    julpath2 = "$(pwd())\\src\\Statistics\\JuliaResults\\3-2-1"

    # all 1 hour treatment by matlab
    matpath1 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_6"
    matpath2 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_8"
    matpath3 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_12"

    matpath4 = "$(pwd())\\src\\Statistics\\MatLabResults\\3hour_ode45_1e_6"

    dstpath1 = "$(pwd())\\src\\Statistics\\Julia_Statistics\\res1.csv"
    dstpath2 = "$(pwd())\\src\\Statistics\\Julia_Statistics\\res2.csv"

    #calculate_signDiffBG(julpath1, julpath2)
    #plot_simulation(julpath1)
    createStatistics(julpath1, dstpath2)
    createStatistics(matpath4, dstpath1)
end