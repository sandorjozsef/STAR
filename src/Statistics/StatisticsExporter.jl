module StatisticsExporter

using Statistics
using CSV
using DataFrames

export writeCSV_HourlyResampledBGStats
function writeCSV_HourlyResampledBGStats(allHourlyBG, fullpath)
    
    # Creating a new dataframe
    mn = DataFrame(HourlyStats = [
    ". . . Hourly Resampled BG stats  ",
    "#Total Hours  ",
    "BG median [IQR] (mmol/L)  ",
    "BG mean (geometric) (mmol/L)  ",
    "BG StDev (geometric) (mmol/L)  ",
    "% BG < 2.2 mmol/L  ",
    "% BG < 4.0 mmol/L  ",
    "% BG < 4.4 mmol/L  ",
    "% BG within 4.4 - 6.1 mmol/L  ",
    "% BG within 4.4 - 7 mmol/L  ",
    "% BG within 4.4 - 8 mmol/L  ",
    "% BG within 4.4 - 9 mmol/L  ",
    "% BG within 6.0 - 9 mmol/L  ",
    "% BG within 8.0 - 10 mmol/L  ",
    "% BG within > 10 mmol/L  ",
    "-----------------------"
    ],
          Value = [
              ". . .",
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
              length(filter(x ->  x > 10.0, allHourlyBG)) / length(allHourlyBG) * 100.0,
              "-----------------------"
          ])
              
  # writing to the newly created file
  CSV.write(fullpath, mn, append = true)
  
end

export writeCSV_RawBGStats
function writeCSV_RawBGStats(allRawBG, RawBG, fullpath)
     # Creating a new dataframe
     mn = DataFrame(RawStats = [
        ". . . Raw BG stats",
        "BG median [IQR] (mmol/L)  ",
        "BG mean (geometric) (mmol/L)  ",
        "BG StDev (geometric) (mmol/L)  ",
        "Num episodes < 4.0 mmol/L  ",
        "Num episodes < 2.22 mmol/L  ",
        "% BG < 2.2 mmol/L  ",
        "% BG < 4.0 mmol/L  ",
        "% BG < 4.4 mmol/L  ",
        "% BG within 4.4 - 6.5 mmol/L  ",
        "% BG within 4.4 - 7.0 mmol/L  ",
        "% BG within 4.4 - 8.0 mmol/L  ",
        "% BG within 8.0 - 10 mmol/L  ",
        "% BG within > 10 mmol/L  ",
        "-----------------------"
        ],
              Value = [
                  ". . .",
                  median(allRawBG),
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
      CSV.write(fullpath, mn, append = true)
end

end