module Visualizer

    using Plots

    export plot_patient_BG
    function plot_patient_BG(Patient1, Patient2)
        p = plot(Patient1.Treal, Patient1.Greal, label = "Method 1", title = Patient1.Name)
        plot!(p, Patient2.Treal, Patient2.Greal, label = "Method 2")
        display(p)
    end

   
    export plot_histogram
    function plot_histogram(array)
        display( histogram(array, bins=range(minimum(array), stop = maximum(array), length = 300), yaxis = :log) )
    end

    function plotCDF(allHourlyBG, path)
        sortedBG = sort(allHourlyBG)
        p = range(0, stop=1, length=length(allHourlyBG))
        cdf = plot(sortedBG, p, label = "egp 1.16", title = "BG CDF - Resampled Hourly")
        xlabel!("BG (mmol/l)")
        ylabel!("Cummulative Freq")
        png(path * "/CDF.png")
    
    end
    
    function plotPatientBG(patient, fullpath)
        p = plot(patient.Treal, patient.Greal, label = "BG")
        plot!(p, patient.Treal_orig, patient.Greal_orig, label ="BG orig")
        xlabel!("time (min)")
        ylabel!("Blood Glucose (mmol/l)")
        png(fullpath)
    end

end