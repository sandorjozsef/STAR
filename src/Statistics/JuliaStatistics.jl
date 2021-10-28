module JuliaStatistics

    include("Serializer.jl")
    include("Visualizer.jl")
    include("StatisticsExporter.jl")
    include("StatisticsCalculator.jl")
    include("VisualizerExporter.jl")
    using .Serializer
    using .Visualizer
    using Statistics
    using .StatisticsExporter
    using .StatisticsCalculator
    using .VisualiserExporter

    RawBG = [] #Vector{Vector{Float64}}
    Treal= [] #Vector{Vector{Float64}}
    GoalFeeds = [] # Vector{Float64}
    HourlyBG = [] #Vector{Vector{Float64}}
    u = [] #Vector{Matrix{Float64}}
    P = [] #Vector{Matrix{Float64}}
    PN = [] #Vector{Matrix{Float64}}
    

    function createDataStructures(srcpath)

        for filename in readdir(srcpath)

            patientName = splitext(filename)[1]
            JuliaPatient = Serializer.deserialize(srcpath, patientName)
            
            push!(Treal, JuliaPatient.Treal)
            push!(RawBG, JuliaPatient.TimeSolnGIQ[:,1])
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
            len = min(length(Patient1.TimeSolnGIQ[:,1]), length(Patient2.TimeSolnGIQ[:,1]))
            for i in 1:len
                if Patient1.Treal[i] == Patient2.Treal[i]
                    push!(signDiffBG, Patient1.TimeSolnGIQ[i,1]-Patient2.TimeSolnGIQ[i,1])
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

            #Visualizer.plot_compare_patient_metabolics(Patient1, Patient2)
            #Visualizer.plot_patient_BG(Patient1, Patient2)
           
        end

        h = Visualizer.plot_histogram(signDiffBG_all)
        display(h)
        VisualiserExporter.savePNG_plot(h, "$(pwd())\\graphs\\asd.png")
        
        println("max diff: ", maximum(signDiffBG_all), " -- ", maxName)
        println("min diff: ", minimum(signDiffBG_all), " -- ", minName)
        println("mean diff: ", Statistics.mean(signDiffBG_all))
        println("std diff: ", Statistics.std(signDiffBG_all))
        println(cnt,"(missed) + ", length(signDiffBG_all))
       
    end

    function plot_simulation(srcpath1)

        for filename in readdir(srcpath1)
            patientName = splitext(filename)[1]
            Patient1 = Serializer.deserialize(srcpath1, patientName)
            p1 = Visualizer.plot_patient_metabolics(Patient1) 
            display(p1)
            VisualiserExporter.savePNG_plot(p1, "$(pwd())\\graphs\\$patientName.png")
            p2 = Visualizer.plotPatientBG(Patient1)
            display(p2)
        end

    end

    function createStatistics(srcpath, dstpath)

        createDataStructures(srcpath)
        if isfile(dstpath)
            rm(dstpath)
        end
        
        w = StatisticsCalculator.wholeCohortStats(RawBG, HourlyBG, Treal)
        StatisticsExporter.writeCSV_Stats(w, dstpath)

        r = StatisticsCalculator.rawBGStats(RawBG)
        StatisticsExporter.writeCSV_Stats(r, dstpath)

        h = StatisticsCalculator.hourlyResampledBGStats(HourlyBG)
        StatisticsExporter.writeCSV_Stats(h, dstpath)

        p = StatisticsCalculator.perEpisode_statistics(RawBG, Treal)
        StatisticsExporter.writeCSV_Stats(p, dstpath)

        ic = StatisticsCalculator.intervention_cohort_stats_hourlyAverage(u, P, PN, GoalFeeds)
        StatisticsExporter.writeCSV_Stats(ic, dstpath)

        ip = StatisticsCalculator.intervention_perEpisode_stats_hourlyAverage(u, P, PN, GoalFeeds)
        StatisticsExporter.writeCSV_Stats(ip, dstpath)

        empty!(RawBG)
        empty!(Treal)
        empty!(u)
        empty!(P)
        empty!(PN)
        empty!(HourlyBG)
        empty!(GoalFeeds)

        println("Created statistics in: $dstpath")
    end

end