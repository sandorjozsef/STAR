
using Statistics
using CSV
using DataFrames

function resampleHourlyBG(patient, timeSoln, t_start)

    if timeSoln.T[end]-60 > t_start
        i = findfirst(x -> x-60 > t_start, timeSoln.T)
        push!(patient.hourlyBG, timeSoln.GIQ[i,1])
    end
    if timeSoln.T[end]-120 > t_start
        i = findfirst(x -> x-120 > t_start, timeSoln.T)
        push!(patient.hourlyBG, timeSoln.GIQ[i,1])
    end
    push!(patient.hourlyBG, timeSoln.GIQ[end,1])
    
end

function writeCSV_ResampledBGStats(allHourlyBG, fullpath)
    
     # Creating a new dataframe
     mn = DataFrame(HourlyStats = [
     "#Total Hours",
     "BG median [IQR] (mmol/L)",
     "BG mean (geometric) (mmol/L)",
     "BG StDev (geometric) (mmol/L)",
     "% BG < 2.2 mmol/L",
     "% BG < 4.0 mmol/L",
     "% BG < 4.4 mmol/L",
     "% BG within 4.4 - 6.1 mmol/L",
     "% BG within 4.4 - 7 mmol/L",
     "% BG within 4.4 - 8 mmol/L",
     "% BG within 4.4 - 9 mmol/L",
     "% BG within 6.0 - 9 mmol/L",
     "% BG within 8.0 - 10 mmol/L",
     "% BG within > 10 mmol/L "
     ],
           Value = [
               length(allHourlyBG) - 112, # 112 = nr of patients
               median(allHourlyBG),
               mean(allHourlyBG),
               std(allHourlyBG),
               length(filter(x -> x < 2.2, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x < 4.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x <= 4.4, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x > 4.4 && x < 6.1, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x > 4.4 && x < 7.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x > 4.4 && x < 8.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x > 4.4 && x < 9.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x > 6.0 && x < 9.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x -> x > 8.0 && x <= 10.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
               length(filter(x ->  x > 10.0, allHourlyBG)) / length(allHourlyBG) * 100.0
           ])
               
   # writing to the newly created file
   CSV.write(fullpath, mn)
   
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