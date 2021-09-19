module Statistics

    include("Serializer.jl")
    using MAT
    using .Serializer
    
    export calculate_signDiff_Jul2Mat
    function calculate_signDiff_Jul2Mat(path)

        for filename in readdir(path)

            JuliaPatient = deserialize(joinpath(path, filename))
            println("JuliaPatient: ")
            display(JuliaPatient)

            MatlabPatient = SerializablePatient()
            patientName = splitext(filename)[1]
            matlabPath = "$(pwd())\\src\\Statistics\\MatLabResults\\SIM_$patientName.mat"
            
            vars = matread(matlabPath)
            MatlabPatient.Greal = vec(vars["PatientStruct"]["Greal"])
            MatlabPatient.Treal = vec(vars["PatientStruct"]["Treal"])
            println("MatlabPatient: ")
            display(MatlabPatient)

            
        end
        
    end

    
end