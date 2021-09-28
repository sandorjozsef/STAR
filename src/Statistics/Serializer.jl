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

    function deserialize(fullpath)
        serPatient = SerializablePatient()
        data = load(fullpath) # it returns a Dictionary
        serPatient.Greal = data["Greal"]
        serPatient.Treal = data["Treal"]
        serPatient.hourlyBG = data["hourlyBG"]
        serPatient.Name = data["Name"]

        return serPatient
    end

    function deserializeMat(fullpath)
        MatlabPatient = SerializablePatient()
        vars = matread(fullpath)
        MatlabPatient.Greal = vec(vars["PatientStruct"]["Greal"])
        MatlabPatient.Treal = vec(vars["PatientStruct"]["Treal"])

        return MatlabPatient
    end

end