module Serializer

    using JLD2
    using FileIO

    export SerializablePatient, serialize, deserialize

    mutable struct SerializablePatient
        Greal::Vector{Float64}
        Treal::Vector{Float64}
        Name::String
        SerializablePatient() = new()
    end

    function serialize(serPatient, fullpath)
        #=T = typeof(serPatient)
        for (name, typ) in zip(fieldnames(T), T.types)
        println("type of the fieldname $name is $typ")
        end=#

        save(fullpath, Dict("Greal" => serPatient.Greal, "Treal" => serPatient.Treal))

    end

    function deserialize(fullpath)
        serPatient = SerializablePatient()
        data = load(fullpath) # it returns a Dictionary
        serPatient.Greal = data["Greal"]
        serPatient.Treal = data["Treal"]

        return serPatient

    end

end