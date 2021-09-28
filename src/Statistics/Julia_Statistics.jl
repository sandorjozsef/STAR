module Julia_Statistics

    include("Serializer.jl")
    include("Visualizer.jl")
    using .Serializer
    using .Visualizer
    using Statistics

    export calculate_signDiffBG_Mat2Jul
    function calculate_signDiffBG_Mat2Jul(path)

        signDiffBG_all = []

        maxi = 0.0
        mini = 0.0
        maxName = ""
        minName = ""

        for filename in readdir(path)

            JuliaPatient = Serializer.deserialize(joinpath(path, filename))
            
            patientName = splitext(filename)[1]
            matlabPath = "$(pwd())\\src\\Statistics\\MatLabResults\\SIM_$patientName.mat"  
            MatlabPatient = Serializer.deserializeMat(matlabPath) 
            
            signDiffBG = []
            len = min(length(MatlabPatient.Greal), length(JuliaPatient.Greal))
            for i in 1:len
                if MatlabPatient.Treal[i] == JuliaPatient.Treal[i]
                    push!(signDiffBG, MatlabPatient.Greal[i]-JuliaPatient.Greal[i])
                end
            end

            if minimum(signDiffBG) < mini
                mini = minimum(signDiffBG)
                minName = JuliaPatient.Name
            end

            if maximum(signDiffBG) > maxi
                maxi = maximum(signDiffBG)
                maxName = JuliaPatient.Name
            end

            signDiffBG_all = cat(signDiffBG_all, signDiffBG, dims=1)
        end

        Visualizer.plot_histogram(signDiffBG_all)
        println("max diff: ", maximum(signDiffBG_all), " -- ", maxName)
        println("min diff: ", minimum(signDiffBG_all), " -- ", minName)
        println("mean diff: ", Statistics.mean(signDiffBG_all))
        println("std diff: ", Statistics.std(signDiffBG_all))
       
    end

    function printData(path)

        for filename in readdir(path)

            JuliaPatient = Serializer.deserialize(joinpath(path, filename))
            display(JuliaPatient.Name)
            display(JuliaPatient.Greal)
            display(JuliaPatient.hourlyBG)

        end
    end


    calculate_signDiffBG_Mat2Jul("D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\JuliaResults\\Simresults-2021-09-27_16_24") 
    #printData("D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\JuliaResults\\Simresults-2021-09-26_15_28")
end