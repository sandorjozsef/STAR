module StatisticsExporter

using Statistics
using CSV
using DataFrames
using Pipe

myDelim = ",   "

export hourlyResampledBGStats
function hourlyResampledBGStats(HourlyBG, fullpath)

    allHourlyBG = []
    for i in 1:length(HourlyBG)
        push!(allHourlyBG, HourlyBG[i]...)
    end
    
    # Creating a new dataframe
    mn = DataFrame( KeyName = [
    ". . . Hourly Resampled BG stats",
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
    "% BG within > 10 mmol/L",
    "-----------------------"
    ],
          Value = [
              ". . .",
              quantile(allHourlyBG, [0.25 0.5 0.75]),
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
              length(filter(x ->  x > 10.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
              "-----------------------"
          ])
              
  # writing to the newly created file
  CSV.write(fullpath, mn, append = true, delim = myDelim, missingstring = "NaN")
  
end

export rawBGStats
function rawBGStats(RawBG, fullpath)

    allRawBG = []
    for i in 1:length(RawBG)
        push!(allRawBG, RawBG[i]...)
    end

     # Creating a new dataframe
     mn = DataFrame(KeyName = [
        ". . . Raw BG stats",
        "BG median [IQR] (mmol/L)",
        "BG mean (geometric) (mmol/L)",
        "BG StDev (geometric) (mmol/L)",
        "Num episodes < 4.0 mmol/L",
        "Num episodes < 2.22 mmol/L",
        "% BG < 2.2 mmol/L",
        "% BG < 4.0 mmol/L",
        "% BG < 4.4 mmol/L",
        "% BG within 4.4 - 6.5 mmol/L",
        "% BG within 4.4 - 7.0 mmol/L",
        "% BG within 4.4 - 8.0 mmol/L",
        "% BG within 8.0 - 10 mmol/L",
        "% BG within > 10 mmol/L",
        "-----------------------"
        ],
              Value = [
                  ". . .",
                  quantile(allRawBG, [0.25 0.5 0.75]),
                  mean(allRawBG),
                  std(allRawBG),
                  length(filter(a -> length([a[i] for i in 1:length(a) if a[i] < 4.0]) != 0, RawBG)),
                  length(filter(a -> length([a[i] for i in 1:length(a) if a[i] < 2.2]) != 0, RawBG)), 
                  length(filter(x -> x < 2.2, allRawBG)) / length(allRawBG) * 100.0,
                  length(filter(x -> x < 4.0, allRawBG)) / length(allRawBG) * 100.0,
                  length(filter(x -> x <= 4.4, allRawBG)) / length(allRawBG) * 100.0,
                  length(filter(x -> x > 4.4 && x < 6.5, allRawBG)) / length(allRawBG) * 100.0,
                  length(filter(x -> x > 4.4 && x < 7.0, allRawBG)) / length(allRawBG) * 100.0,
                  length(filter(x -> x > 4.4 && x < 8.0, allRawBG)) / length(allRawBG) * 100.0,
                  length(filter(x -> x > 8.0 && x <= 10.0, allRawBG)) / length(allRawBG) * 100.0,
                  length(filter(x ->  x > 10.0, allRawBG)) / length(allRawBG) * 100.0,
                  "-----------------------"
              ])
                  
      # writing to the newly created file
      CSV.write(fullpath, mn, append = true, delim = myDelim, missingstring = "NaN")
end

export wholeCohortStats
function wholeCohortStats(RawBG, HourlyBG, fullpath)

    allRawBG = [RawBG[i][j] for i in 1:length(RawBG) for j in 1:length(RawBG[i])]
    allHourlyBG = [HourlyBG[i][j] for i in 1:length(HourlyBG) for j in 1:length(HourlyBG[i])]

    mn = DataFrame(KeyName = [
        ". . . Whole Cohort Statistics",
        "Num Episodes",
        "Total Hours",
        "Num BG measurements",
        "Average time of hours analysed (Days)",
        "Median time of hours analysed [IQR] (Days)",
        "Mean Measures/day (Cohort)",
        "Median [IQR] Measures/day (Per-Patient)",
        "-----------------------"
        ],
              Value = [
                  ". . .",
                  length(RawBG),
                  length(allHourlyBG),
                  length(allRawBG),
                  mean([length(HourlyBG[i])/24.0 for i in 1:length(HourlyBG)]),
                  quantile([length(HourlyBG[i])/24.0 for i in 1:length(HourlyBG)], [0.25 0.5 0.75]), 
                  length(allRawBG) / (length(allHourlyBG) / 24),
                  quantile([length(RawBG[i])/(length(HourlyBG[i])/24.0) for i in 1:length(RawBG)], [0.25 0.5 0.75]),
                  "-----------------------"
              ])
                  
      # writing to the newly created file
      CSV.write(fullpath, mn, append = false, delim = myDelim, missingstring = "NaN")
end

export intervention_cohort_stats_hourlyAverage
function intervention_cohort_stats_hourlyAverage(u, P, PN, fullpath)
 
    u_all = []
    for i in 1:length(u)
        u_ = resample_hourly_insulin(u[i])
        push!(u_all, u_...)
    end

    P_all = []
    for i in 1:length(u)
        P_ = resample_hourly_enteral_glucose(P[i])
        push!(P_all, P_...)
    end

    PN_all = []
    for i in 1:length(PN)
        PN_ = resample_hourly_parenteral_glucose(PN[i])
        push!(PN_all, PN_...)
    end

    mn = DataFrame(KeyName = [
        ". . . Intervention Cohort Stats (Hourly Average)",
        "Median insulin rate [IQR] (U/hr)",
        "Feed Stats All",
        "Median glucose rate [IQR] (g/hour)",
        "Median glucose rate [IQR] (% goal)",
        "Median Enteral glucose [IQR] (g/hour)",
        "Median Parental glucose [IQR] (g/hour)",
        "Feed Stats Excluding those not fed",
        "Total hours not fed",
        "Median glucose rate [IQR] (g/hour)",
        "Median glucose rate [IQR] (% goal)",
        "Median Enteral glucose [IQR] (g/hour)",
        "Median Parental glucose [IQR] (g/hour)",
        "-----------------------"
        ],
              Value = [
                  ". . .",
                  quantile(u_all, [0.25, 0.5, 0.75]),
                  "",
                  quantile(map(x -> x * 180 * 60 / 1000, P_all + PN_all), [0.25, 0.5, 0.75]), # convert mmol/min to g/hour
                  missing,
                  quantile(P_all, [0.25, 0.5, 0.75]),
                  quantile(PN_all, [0.25, 0.5, 0.75]),
                  "",
                  length(filter(x -> x == 0, P_all)),
                  (@pipe (P_all + PN_all) |> 
                   filter(x -> x != 0, _) |> 
                   map(x -> x * 180 * 60 / 1000, _) |> 
                   quantile(_, [0.25, 0.5, 0.75]) ),
                  missing,
                  (@pipe P_all |> 
                   filter(x -> x!=0,_) |> 
                   map(x -> x * 180 * 60 / 1000, _) |> 
                   quantile(_, [0.25, 0.5, 0.75]) ),
                  (@pipe PN_all |> 
                   filter(x -> x!=0,_) |> 
                   map(x -> x * 180 * 60 / 1000, _) |> 
                   quantile(_, [0.25, 0.5, 0.75]) ),
                  "-----------------------"
              ])
                  
      # writing to the newly created file
      CSV.write(fullpath, mn, append = true, delim = myDelim, missingstring = "NaN")

end

function resample_hourly_insulin(u)

    # u[:,1] -> 0 1 60 61 180 181 240 241 ... minutes
    # u[:,2] -> 16.66 33.33 50 66.66 83.33 100 116.66 113.33 150 166.66 -- mUnit/min
    # u[:,2] * 60 / 1000 -> Unit/hour
    u_hourly = []
    for i in 1:2:(length(u[:,1])-3) # start : stepsize : end
        push!(u_hourly, trunc( u[i,2] * 60 / 1000)) # convert to Unit/hour
        if (u[i+3,1] - u[i+1,1]) == 120 # the patient got the insulin for 2 hour
            push!(u_hourly, trunc( u[i,2] * 60 / 1000)) # convert to Unit/hour
        end
        if (u[i+3,1] - u[i+1,1]) == 180 #the patient got the insulin for 3 hour
            push!(u_hourly, trunc( u[i,2] * 60 / 1000)) # convert to Unit/hour
            push!(u_hourly, trunc( u[i,2] * 60 / 1000))
        end
    end
    push!(u_hourly, trunc( u[end,2] * 60 / 1000)) # the last one supposed that lasted for 1 hour

    return u_hourly

end

function resample_hourly_enteral_glucose(P)
    
    P_hourly = []
    for i in 1:(length(P[:,1])-1)
        push!(P_hourly, P[i,2])
        if (P[i+1,1] - P[i,1]) == 120
            push!(P_hourly, P[i,2])
        end
        if (P[i+1,1] - P[i,1]) == 180
            push!(P_hourly, P[i,2])
            push!(P_hourly, P[i,2])
        end
    end
    push!(P_hourly, P[end,2]) # the last one supposed 1 hour

    return P_hourly
    
end

function resample_hourly_parenteral_glucose(PN)
    #PN[:,1] -> 0 5 60 65 180 185 ...
    
    PN_hourly = []
    for i in 1:2:(length(PN[:,1])-2)
        push!(PN_hourly, PN[i,2] / 12.0) # bolus mmol/min for 5 min -> mmol/min for 60 min
        if (PN[i+2,1] - PN[i,1]) == 120
            push!(P_hourly, PN[i,2])
        end
        if (PN[i+2,1] - PN[i,1]) == 180
            push!(PN_hourly, PN[i,2])
            push!(PN_hourly, PN[i,2])
        end
    end
    push!(PN_hourly, PN[end-1,2]) # the last one supposed 1 hour

    return PN_hourly
    
end

export intervention_perEpisode_stats_hourlyAverage
function intervention_perEpisode_stats_hourlyAverage(u, P, PN, fullpath)

    Feed_all = map(x -> resample_hourly_parenteral_glucose(x), PN) + map(x -> resample_hourly_enteral_glucose(x), P)

    mn = DataFrame(KeyName = [
        ". . . Intervention Per-episode Stats (Hourly Average)",
        "Median insulin rate [IQR] (U/hr)",
        "Feed Stats All",
        "Median glucose rate [IQR] (g/hour)",
        "Median glucose rate [IQR] (% goal)",
        "Median Enteral glucose [IQR] (g/hour)",
        "Median Parental glucose [IQR] (g/hour)",
        "Feed Stats Excluding those not fed",
        "Total hours not fed",
        "Median glucose rate [IQR] (g/hour)",
        "Median glucose rate [IQR] (% goal)",
        "Median Enteral glucose [IQR] (g/hour)",
        "Median Parental glucose [IQR] (g/hour)",
        "-----------------------"
        ],
              Value = [
                  ". . .",
                  (@pipe u |>
                   map(x -> resample_hourly_insulin(x), _) |>
                   map(x -> mean(x), _) |>
                   quantile(_, [0.25, 0.5, 0.75])),
                  "",
                  (@pipe Feed_all |>
                   map(x -> mean(x), _) |>
                   map(x -> x * 180 * 60 / 1000, _) |>
                   quantile(_, [0.25, 0.5, 0.75])), # convert mmol/min to g/hour
                  missing,
                  (@pipe P |>
                   map(x -> resample_hourly_enteral_glucose(x), _) |>
                   map(x -> mean(x), _) |>
                   map(x -> x * 180 * 60 / 1000, _) |>
                   quantile(_, [0.25, 0.5, 0.75])),
                  (@pipe PN |>
                   map(x -> resample_hourly_parenteral_glucose(x), _) |>
                   map(x -> mean(x), _) |>
                   map(x -> x * 180 * 60 / 1000, _) |>
                   quantile(_, [0.25, 0.5, 0.75])),
                  "",
                  (@pipe Feed_all |>
                   map(x -> filter(y -> y == 0, x), _) |>
                   map(x -> length(x), _) |> sum ),
                  (@pipe Feed_all |>
                   map(x -> filter(y -> y != 0, x), _) |>
                   map(x -> mean(x), _) |> 
                   map(x -> x * 180 * 60 / 1000, _) |> 
                   quantile(_, [0.25, 0.5, 0.75]) ),
                  missing,
                  (@pipe P |> 
                   map(x -> resample_hourly_enteral_glucose(x), _) |> 
                   map(x -> filter(y -> y != 0, x), _) |> 
                   map(x -> mean(x), _) |> 
                   map(x -> x * 180 * 60 / 1000, _) |> 
                   quantile(_, [0.25, 0.5, 0.75])),
                  (@pipe PN |> 
                   map(x -> resample_hourly_parenteral_glucose(x), _) |> 
                   map(x -> filter(y -> y != 0, x), _) |> 
                   filter(x -> x != [], _) |> 
                   map(x -> mean(x), _) |> 
                   map(x -> x * 180 * 60 / 1000, _) |> 
                   quantile(_, [0.25, 0.5, 0.75])),
                  "-----------------------"
              ])
                  
      # writing to the newly created file
      CSV.write(fullpath, mn, append = true, delim = myDelim, missingstring = "NaN")


end

export perEpisode_statistics
function perEpisode_statistics(RawBG, Treal, fullpath)

    mn = DataFrame(KeyName = [
        ". . . Per-episode statistics (Median [IQR])",
        "*** Raw BG Stats ***",
        "Hours of control",
        "Num BG measurements",
        "Initial BG (mmol/L)",
        "BG median (mmol/L)",
        "BG mean (mmol/L)",
        "BG StDev (mmol/L)",
        "%BG > 10.0 mmol/L",
        "%BG within 4.0-6.1 mmol/L",
        "%BG within 4.0-7.0 mmol/L",
        "%BG within 4.0-8.0 mmol/L",
        "%BG < 4.4 mmol/L",
        "%BG < 4.0 mmol/L",
        "%BG < 2.22 mmol/L",
        "-----------------------"
        ],
              Value = [
                  ". . .",
                  "",
                  quantile(Treal[:][end] / 60, [0.25 0.5 0.75]),
                  quantile([ length(RawBG[i]) for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ RawBG[i][1] for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ median(RawBG[i]) for i in 1:length(RawBG) ], [0.25 0.5 0.75]), 
                  quantile([ mean(RawBG[i]) for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ std(RawBG[i]) for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ length(filter(x ->  x > 10.0, RawBG[i])) / length(RawBG[i]) * 100.0 for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ length(filter(x ->  x > 4.0 && x < 6.1, RawBG[i])) / length(RawBG[i]) * 100.0 for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ length(filter(x ->  x > 4.0 && x < 7.0, RawBG[i])) / length(RawBG[i]) * 100.0 for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ length(filter(x ->  x > 4.0 && x < 8.0, RawBG[i])) / length(RawBG[i]) * 100.0 for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ length(filter(x ->  x < 4.4 , RawBG[i])) / length(RawBG[i]) * 100.0 for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ length(filter(x ->  x < 4.0 , RawBG[i])) / length(RawBG[i]) * 100.0 for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  quantile([ length(filter(x ->  x < 2.22 , RawBG[i])) / length(RawBG[i]) * 100.0 for i in 1:length(RawBG) ], [0.25 0.5 0.75]),
                  "-----------------------"
              ])
                  
      # writing to the newly created file
      CSV.write(fullpath, mn, append = true, delim = myDelim, missingstring = "NaN")
end


end