module Statistics

    include("Serializer.jl")
    include("Visualizer.jl")
    using MAT
    using Plots
    using .Serializer
    using .Visualizer

    export calculate_signDiffBG_Mat2Jul
    function calculate_signDiffBG_Mat2Jul(path)

        for filename in readdir(path)

            JuliaPatient = deserialize(joinpath(path, filename))
            
            MatlabPatient = SerializablePatient()
            patientName = splitext(filename)[1]
            matlabPath = "$(pwd())\\src\\Statistics\\MatLabResults\\SIM_$patientName.mat"
            
            vars = matread(matlabPath)
            MatlabPatient.Greal = vec(vars["PatientStruct"]["Greal"])
            MatlabPatient.Treal = vec(vars["PatientStruct"]["Treal"])
            MatlabPatient.Name = patientName
            
            try 
                Visualizer.plot_SignDiffBG_Mat2Jul(MatlabPatient, JuliaPatient) 
            catch
                println(patientName)
            end
            
        end

        
    end


    calculate_signDiffBG_Mat2Jul("D:\\EGYETEM\\7.sem\\Szakdolgozat\\simulator_julia\\src\\Statistics\\JuliaResults\\Simresults-2021-09-20_15_30") 
    
end