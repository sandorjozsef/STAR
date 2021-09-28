module Visualizer

    using Plots

    export plot_Mat_Jul_patient
    function plot_Mat_Jul_patient(MatlabPatient, JuliaPatient)
        p = plot(MatlabPatient.Treal, MatlabPatient.Greal, label = "MAT", title = JuliaPatient.Name)
        plot!(p, JuliaPatient.Treal, JuliaPatient.Greal, label = "JUL")
        display(p)
    end

    export plot_Treals
    function plot_Treals(MatlabPatient, JuliaPatient)
        p = plot(MatlabPatient.Treal, label = "MAT T", title = JuliaPatient.Name)
        plot!(p, JuliaPatient.Treal, label = "JUL T")
        display(p)
    end

    export plot_histogram
    function plot_histogram(array)
        display(histogram(array, bins=range(minimum(array), stop = maximum(array), length = 25)))
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