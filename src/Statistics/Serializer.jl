module Serializer

    using JLD2
    using FileIO
    using MAT

    export SerializablePatient, serialize, deserialize, deserializeMat

    mutable struct SerializablePatient
        Greal::Vector{Float64}
        Treal::Vector{Float64}
        hourlyBG::Vector{Float64}
        Name::String
        SerializablePatient() = new()
    end

    function serialize(serPatient, fullpath)
        #=T = typeof(serPatient)
        for (name, typ) in zip(fieldnames(T), T.types)
        println("type of the fieldname $name is $typ")
        end=#

        save(fullpath, Dict("Greal" => serPatient.Greal,
         "Treal" => serPatient.Treal,
         "hourlyBG" => serPatient.hourlyBG,
         "Name" => serPatient.Name
         ))

    end

    function deserialize(path, patientName, type)

        Patient = SerializablePatient()
        if type == "JUL"
            data = load(path * "\\$patientName" * ".jld2") # it returns a Dictionary
            Patient.Greal = data["Greal"]
            Patient.Treal = data["Treal"]
            Patient.hourlyBG = data["hourlyBG"]
            Patient.Name = data["Name"]
        elseif type == "MAT"
            vars = matread(path * "\\SIM_$patientName" * ".mat")
            Patient.Greal = vec(vars["PatientStruct"]["Greal"])
            Patient.Treal = vec(vars["PatientStruct"]["Treal"])
            Patient.Name = patientName
        else
            throw(ArgumentError("Not existing serializable type."))
        end
        
        return Patient
    end


end