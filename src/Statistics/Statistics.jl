module Statistics

    using MAT
    using JLD2
    using FileIO

    export SerializablePatient
    mutable struct SerializablePatient
        Greal::Array{Float64,1}
        T::Float64
        SerializablePatient() = new()
    end

    export calculate_signDiff_Jul2Mat
    function calculate_signDiff_Jul2Mat()
       
        name = "0d7eebb1-64da-4852-a042-2445e24931d0"
        path = "$(pwd())\\src\\Statistics\\MatLabResults\\SIM_$name.mat"
        file = matopen(path)
        if haskey(file, "PatientStruct")
            vars = matread(path)
            Greal_Mat = vars["PatientStruct"]["Greal"]
        end
        close(file)

        data = load("$(pwd())\\src\\Statistics\\JuliaResults\\Simresults-2021-09-17_23_22\\$name.jld2") #Dict
        display(data)
    end

    
end