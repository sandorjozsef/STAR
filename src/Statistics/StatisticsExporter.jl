module StatisticsExporter

using Statistics
using CSV
using DataFrames

myDelim = ",   "

export hourlyResampledBGStats
function hourlyResampledBGStats(allHourlyBG, fullpath)
    
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
function rawBGStats(allRawBG, RawBG, fullpath)
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
function intervention_cohort_stats_hourlyAverage()
    #TODO
end

export intervention_perEpisode_stats_hourlyAverage
function intervention_perEpisode_stats_hourlyAverage()
    #TODO
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