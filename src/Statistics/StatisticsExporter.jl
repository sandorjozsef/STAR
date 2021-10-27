module StatisticsExporter

    using CSV
    using DataFrames

    myDelim = ",   "

    export writeCSV_Stats
    function writeCSV_Stats(mn, fullpath)

        # writing to the newly created file
        CSV.write(fullpath, mn, append = true, delim = myDelim, missingstring = "NaN")

    end

end