module Serializer

    using JLD2
    using FileIO
    using MAT

    export SerializablePatient, serialize, deserialize, deserializeMat

    mutable struct SerializablePatient
        Treal::Vector{Float64}
        GIQ::Matrix{Float64}
        PN::Matrix{Float64}
        P::Matrix{Float64}
        rawSI::Matrix{Float64}
        hourlyBG::Vector{Float64}
        Name::String
        SerializablePatient() = new()
    end

    function serialize(serPatient, fullpath)
        #=T = typeof(serPatient)
        for (name, typ) in zip(fieldnames(T), T.types)
        println("type of the fieldname $name is $typ")
        end=#

        save(fullpath, Dict(
         "GIQ" => serPatient.GIQ,
         "Treal" => serPatient.Treal,
         "P" => serPatient.P,
         "PN" => serPatient.PN,
         "rawSI" => serPatient.rawSI,
         "hourlyBG" => serPatient.hourlyBG,
         "Name" => serPatient.Name
         ))

    end

    function deserialize(path, patientName, type)

        Patient = SerializablePatient()
        if type == "JUL"

            data = load(path * "\\$patientName" * ".jld2") # it returns a Dictionary
            Patient.GIQ = data["GIQ"]
            Patient.Treal = data["Treal"]
            Patient.P = data["P"]
            Patient.PN = data["PN"]
            Patient.GIQ = data["GIQ"]
            Patient.rawSI = data["rawSI"]
            Patient.hourlyBG = data["hourlyBG"]
            Patient.Name = data["Name"]

        elseif type == "MAT"
            if contains(patientName, "SIM_")
                patientName = replace(patientName, "SIM_" => "", count = 1)
            end
            vars = matread(path * "\\SIM_$patientName" * ".mat")
            Patient.GIQ = [vec(vars["PatientStruct"]["Greal"]) zeros(203) zeros(203)]
            Patient.Treal = vec(vars["PatientStruct"]["Treal"])
           
            #Patient.P = [ vec(vars["PatientStruct"]["P"][:,1]) vec(vars["PatientStruct"]["P"][:,2]) ]
            #Patient.PN = vars["PatientStruct"]["PN"]
            #Patient.rawSI = vars["PatientStruct"]["rawSI"]
            Patient.hourlyBG = [0.0]
            Patient.Name = patientName
        else
            throw(ArgumentError("Not existing serializable type."))
        end
        
        return Patient
    end


end