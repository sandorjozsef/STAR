module Visualizer

    using Plots

    export plot_compare_methods_BG
    function plot_compare_methods_BG(Patient1, Patient2)
        p = plot(Patient1.Treal, Patient1.TimeSolnGIQ[:,1], label = "Method 1", title = Patient1.Name)
        plot!(p, Patient2.Treal, Patient2.TimeSolnGIQ[:,1], label = "Method 2")
        hspan!(p,[4.4,8.0], color = :green, alpha = 0.2, labels = "normoglycaemia (4.4 - 8.0)");
        display(p)
    end

    export plot_patient_metabolics
    function plot_patient_metabolics(Patient)
        p1 = plot(Patient.Treal, Patient.TimeSolnGIQ[:,1], label = "G", title = Patient.Name)
        plot!(p1, Patient.Treal, Patient.TimeSolnGIQ[:,2] / 10.0, label = "I / 10")
        plot!(p1, Patient.Treal, Patient.TimeSolnGIQ[:,3] / 10.0, label = "Q / 10")
        hspan!(p1,[4.4,8.0], color = :green, alpha = 0.2, labels = "normoglycaemia (4.4 - 8.0)");
        P = convert_to_stepfunction(Patient.P)
        p2 = plot(P[2:end,1], P[1:(end-1),2], label = "P")
        plot!(p2, Patient.PN[:,1], Patient.PN[:,2], label = "PN")
        plot!(p2, Patient.u[2:end,1], Patient.u[1:(end-1),2]/100, label = "u / 100 (mUnit/min)")
        SI = convert_to_stepfunction(Patient.rawSI)
        p3 = plot(SI[2:end,1], SI[1:(end-1),2], label = "SI", xlabel = "time (min)", ylims = (0, 0.005))
        p = plot(p1,p2, p3, layout = (3,1), size = (1000, 900), minorgrid = true)
        display(p)
        #png(p, pwd() * "\\graphs\\$(Patient.Name)")
    end

    export plot_compare_patient_metabolics
    function plot_compare_patient_metabolics(Patient1, Patient2)
        p1 = plot(Patient1.Treal, Patient1.TimeSolnGIQ[:,1], label = "G1 (mmol/l)", title = Patient1.Name)
        plot!(p1, Patient2.Treal, Patient2.TimeSolnGIQ[:,1], label = "G2 (mmol/l)")
        hspan!(p1,[4.4,8.0], color = :green, alpha = 0.2, labels = "normoglycaemia (4.4 - 8.0)");

        p2 = plot( Patient1.u[2:end,1], Patient1.u[1:(end-1),2] , label = "u1 (mUnit/min)")
        plot!(p2, Patient2.u[2:end,1], Patient2.u[1:(end-1),2] , label = "u2 (mUnit/min)")

        P1 = convert_to_stepfunction(Patient1.P)
        P2 = convert_to_stepfunction(Patient2.P)

        p3 = plot(P1[2:end,1], P1[1:(end-1),2], label = "P1")
        plot!(p3, P2[2:end,1], P2[1:(end-1),2], label = "P2")
        plot!(p3, Patient1.PN[:,1], Patient1.PN[:,2], label = "PN1")
        plot!(p3, Patient2.PN[:,1], Patient2.PN[:,2], label = "PN2")

        SI = convert_to_stepfunction(Patient1.rawSI)
        p4 = plot(SI[2:end,1], SI[1:(end-1),2], label = "SI", xlabel = "time (min)", ylims = (0, 0.005))
        p = plot(p1,p2, p3,p4, layout = (4,1), size = (1000, 1200), minorgrid = true)
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
        display(p)
        #png(p, path * "/CDF.png")
    
    end
    
    function plotPatientBG(patient)
        p = plot(patient.Treal, patient.Greal, label = "BG")
        plot!(p, patient.Treal_orig, patient.Greal_orig, label ="BG orig")
        xlabel!("time (min)")
        ylabel!("Blood Glucose (mmol/l)")
        hspan!(p,[4.4,8.0], color = :green, alpha = 0.2, labels = "normoglycaemia (4.4 - 8.0)");
        display(p)
    end

    function convert_to_stepfunction(f::Matrix{Float64})
        s = [f[1,1] f[1,2]]
        s = [s; f[1,1]+1 f[1,2]]
        for i in 2:length(f[:,1])
            s = [s; f[i,1] f[i,2]]
            s = [s; f[i,1]+1 f[i,2]]
        end
        return s
    end

end