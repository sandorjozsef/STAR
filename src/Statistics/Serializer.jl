module Serializer

    using JLD2
    using FileIO
    using MAT

    export SerializablePatient, serialize, deserialize

    mutable struct SerializablePatient
        Treal::Vector{Float64}
        GIQ::Matrix{Float64}
        PN::Matrix{Float64}
        P::Matrix{Float64}
        u::Matrix{Float64}
        rawSI::Matrix{Float64}
        hourlyBG::Vector{Float64}
        Name::String
        SerializablePatient() = new()
    end

    function serialize(serPatient, fullpath)
        # serialize to jld2 file format
        save(fullpath, Dict(
         "GIQ" => serPatient.GIQ,
         "Treal" => serPatient.Treal,
         "P" => serPatient.P,
         "PN" => serPatient.PN,
         "rawSI" => serPatient.rawSI,
         "u" => serPatient.u,
         "hourlyBG" => serPatient.hourlyBG,
         "Name" => serPatient.Name
         ))

    end

    function deserialize(path, patientName)

        Patient = SerializablePatient()
        type = splitext(readdir(path)[1])[2]
        if type == ".jld2"
            if contains(patientName, "SIM_")
                patientName = replace(patientName, "SIM_" => "", count = 1)
            end
            data = load(path * "\\$patientName" * ".jld2") # it returns a Dictionary
            Patient.GIQ = data["GIQ"]
            Patient.Treal = data["Treal"]
            Patient.P = data["P"]
            Patient.PN = data["PN"]
            Patient.GIQ = data["GIQ"]
            Patient.rawSI = data["rawSI"]
            Patient.u = data["u"]
            Patient.hourlyBG = data["hourlyBG"]
            Patient.Name = data["Name"]

        elseif type == ".mat"

            if contains(patientName, "SIM_")
                patientName = replace(patientName, "SIM_" => "", count = 1)
            end
            vars = matread(path * "\\SIM_$patientName" * ".mat")
            dense_GIQ = vars["TimeSoln"]["GIQ"]
            Greal = vec(vars["PatientStruct"]["Greal"])
            Patient.GIQ = createGIQ(Greal, dense_GIQ)
            Patient.Treal = vec(vars["PatientStruct"]["Treal"])
            Patient.P = [ vars["PatientStruct"]["P"][1] vars["PatientStruct"]["P"][2] ]
            Patient.PN = [ vars["PatientStruct"]["PN"][1] vars["PatientStruct"]["PN"][2] ]
            Patient.rawSI = [ vars["PatientStruct"]["rawSI"][1] vars["PatientStruct"]["rawSI"][2] ]
            Patient.u = [ vars["PatientStruct"]["u"][1] vars["PatientStruct"]["u"][2] ]
            Patient.hourlyBG = [0.0]
            Patient.Name = patientName

        else
            throw(ArgumentError("Not existing serializable type."))
        end
        
        return Patient
    end

    function createGIQ(Greal::Vector{Float64}, dense_GIQ::Matrix{Float64})
        j = 2
        rare_GIQ = [dense_GIQ[1,1] dense_GIQ[1,2] dense_GIQ[1,3]]
        for i in 2:length(dense_GIQ[:,1])
            if Greal[j] == dense_GIQ[i,1]
                rare_GIQ = [rare_GIQ ; dense_GIQ[i,1] dense_GIQ[i,2] dense_GIQ[i,3]]
                j = j+1
            end
        end
        return rare_GIQ
    end

end