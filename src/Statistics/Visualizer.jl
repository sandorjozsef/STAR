module Visualizer

    using Plots

    export plot_patient_BG
    function plot_patient_BG(Patient1, Patient2)
        p = plot(Patient1.Treal, Patient1.GIQ[:,1], label = "Method 1", title = Patient1.Name)
        plot!(p, Patient2.Treal, Patient2.GIQ[:,1], label = "Method 2")
        display(p)
    end

    export plot_patient_metabolics
    function plot_patient_metabolics(Patient)
        p1 = plot(Patient.Treal, Patient.GIQ[:,1], label = "G", title = Patient.Name)
        plot!(p1, Patient.Treal, Patient.GIQ[:,2] / 10.0, label = "I / 10")
        plot!(p1, Patient.Treal, Patient.GIQ[:,3] / 10.0, label = "Q / 10")
        p2 = plot(Patient.P[:,1], Patient.P[:,2], label = "P")
        plot!(p2, Patient.PN[:,1], Patient.PN[:,2], label = "PN")
        p3 = plot(Patient.rawSI[:,1], Patient.rawSI[:,2], label = "SI", xlabel = "time (min)")
        display(plot(p1,p2, p3, layout = (3,1), size = (800, 1000)))
    end

    export plot_compare_patient_metabolics
    function plot_compare_patient_metabolics(Patient1, Patient2)
        p1 = plot(Patient1.Treal, Patient1.GIQ[:,1], label = "G1", title = Patient1.Name)
        plot!(p1, Patient2.Treal, Patient2.GIQ[:,1], label = "G2", ylabel = "BG (mmol/l)")

        p2 = plot(Patient1.Treal, Patient1.GIQ[:,2] / 10.0, label = "I1")
        plot!(p2, Patient2.Treal, Patient2.GIQ[:,2] / 10.0, label = "I2")

        p3 = plot( Patient1.Treal, Patient1.GIQ[:,3] / 10.0, label = "Q1")
        plot!(p3, Patient2.Treal, Patient2.GIQ[:,3] / 10.0, label = "Q2")

        p4 = plot(Patient1.P[:,1], Patient1.P[:,2], label = "P1")
        plot!(p4, Patient1.PN[:,1], Patient1.PN[:,2], label = "PN1")
        plot!(p4, Patient2.P[:,1], Patient2.P[:,2], label = "P2")
        plot!(p4, Patient2.PN[:,1], Patient2.PN[:,2], label = "PN2", xlabel = "time (min)")

        p = plot(p1,p2, p3, p4, layout = (4,1), size = (1200, 1200))
        display(p)
        #png(p, pwd() * "\\graphs\\$(Patient1.Name)")
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