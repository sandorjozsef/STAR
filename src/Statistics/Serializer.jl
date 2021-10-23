module Serializer

    include("$(pwd())//src//JavaCall//javaCallHelper.jl")
    include("$(pwd())//src//Simulation_Structs.jl")
    using JLD2
    using FileIO
    using MAT
    using .Simulation_Structs

    export SerializablePatient, serialize, deserialize

    mutable struct SerializablePatient
        Treal::Vector{Float64}
        Greal::Vector{Float64}
        GIQ::Matrix{Float64}
        PN::Matrix{Float64}
        P::Matrix{Float64}
        u::Matrix{Float64}
        rawSI::Matrix{Float64}
        hourlyBG::Vector{Float64}
        Name::String
        GoalFeed::Float64
        Po::Float64
        Uo::Float64
        SerializablePatient() = new()
    end

    function serialize(serPatient, fullpath)
        # serialize to jld2 file format
        save(fullpath, Dict(
         "GIQ" => serPatient.GIQ,
         "Treal" => serPatient.Treal,
         "Greal" => serPatient.Greal,
         "P" => serPatient.P,
         "PN" => serPatient.PN,
         "rawSI" => serPatient.rawSI,
         "u" => serPatient.u,
         "hourlyBG" => serPatient.hourlyBG,
         "Name" => serPatient.Name,
         "GoalFeed" => serPatient.GoalFeed,
         "Po" => serPatient.Po,
         "Uo" => serPatient.Uo
         ))

    end

    function deserialize(path, patientName)

        Patient = SerializablePatient()
        type = splitext(readdir(path)[1])[2]
        fileName = splitext(readdir(path)[1])[1]
        if type == ".jld2"

            data = load(path * "\\$patientName" * ".jld2") # it returns a Dictionary
            
            Patient.Treal = data["Treal"]
            Patient.Greal = data["Greal"]
            dense_GIQ = data["GIQ"]
            Patient.GIQ = createGIQ(Patient.Greal, dense_GIQ)
            Patient.P = data["P"]
            Patient.PN = data["PN"]
            Patient.rawSI = data["rawSI"]
            Patient.u = data["u"]
            Patient.hourlyBG = data["hourlyBG"]
            Patient.Name = data["Name"]
            Patient.GoalFeed = data["GoalFeed"]
            Patient.Po = data["Po"]
            Patient.Uo = data["Uo"]

        elseif type == ".mat"
            vars = undef
            if ispath(path * "\\$patientName" * ".mat")
                vars = matread(path * "\\$patientName" * ".mat")
            else 
                vars = matread(path * "\\SIM_$patientName" * ".mat")
            end

            Patient.Greal = vec(vars["PatientStruct"]["Greal"])
            Patient.Treal = vec(vars["PatientStruct"]["Treal"])
            Patient.hourlyBG = [0.0]
            Patient.Uo = vars["PatientStruct"]["Uo"]
            Patient.Po = vars["PatientStruct"]["Po"]
            
            if contains(fileName, "SIM_") # simulated values
                patientName = replace(fileName, "SIM_" => "", count = 1)
                dense_GIQ = vars["TimeSoln"]["GIQ"]
                Patient.GIQ = createGIQ(Patient.Greal, dense_GIQ)
                Patient.GoalFeed = vars["PatientStruct"]["GoalFeed"]
                Patient.P = [ vars["PatientStruct"]["P"][1] vars["PatientStruct"]["P"][2] ]
                Patient.PN = [ vars["PatientStruct"]["PN"][1] vars["PatientStruct"]["PN"][2] ]
                Patient.u = [ vars["PatientStruct"]["u"][1] vars["PatientStruct"]["u"][2] ]
                Patient.rawSI = [ vars["PatientStruct"]["rawSI"][1] vars["PatientStruct"]["rawSI"][2] ]
            else
                Patient.GIQ = [0 0 0]
                Patient.GoalFeed = Patient.Po
                Patient.P = vars["PatientStruct"]["P"]
                Patient.PN = vars["PatientStruct"]["PN"]
                Patient.u =  vars["PatientStruct"]["u"]
                Patient.rawSI = vars["PatientStruct"]["rawSI"]
            end
            Patient.Name = patientName

        elseif type == ""

            #PatientStruct
            loadPatientStruct(Patient, path *"\\"* patientName *"\\"* patientName *".PatientStruct")
            Patient.GoalFeed = Patient.Po
            Patient.hourlyBG = [0.0]
            #TimeSoln
            timeSoln = Simulation_Structs.TimeSoln()
            loadTimeSoln(timeSoln, path *"\\"* patientName *"\\"* patientName *".TimeSoln")
            dense_GIQ = timeSoln.GIQ
            Patient.GIQ = createGIQ(Patient.Greal, dense_GIQ)
            

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