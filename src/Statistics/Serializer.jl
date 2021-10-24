module Serializer

    include("$(pwd())//src//JavaCall//JavaCallHelper.jl")
    include("$(pwd())//src//Simulation_Structs.jl")
    using JLD2
    using FileIO
    using MAT
    using .Simulation_Structs
    using .JavaCallHelper

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
        Treal_orig::Vector{Float64}
        Greal_orig::Vector{Float64}
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
         "Uo" => serPatient.Uo,
         "Greal_orig" => serPatient.Greal_orig,
         "Treal_orig" => serPatient.Treal_orig,
         ))

    end

    function deserialize(path, patientName)

        Patient = SerializablePatient()
        type = splitext(readdir(path)[1])[2]

        if type == ".jld2"

            patientName = replace(patientName, "SIM_" => "", count = 1)
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
            Patient.Treal_orig = data["Treal_orig"]
            Patient.Greal_orig = data["Greal_orig"]

        elseif type == ".mat"

            vars = undef
            if ispath(path * "\\$patientName" * ".mat")
                vars = matread(path * "\\$patientName" * ".mat")
            else 
                vars = matread(path * "\\SIM_$patientName" * ".mat")
                patientName = "SIM_$patientName"
            end

            Patient.Greal = vec(vars["PatientStruct"]["Greal"])
            Patient.Treal = vec(vars["PatientStruct"]["Treal"])
            Patient.hourlyBG = [0.0]
            Patient.Uo = vars["PatientStruct"]["Uo"]
            Patient.Po = vars["PatientStruct"]["Po"]
            Patient.Greal_orig = [0.0]
            Patient.Treal_orig = [0.0]
            
            if contains(patientName, "SIM_") # simulated values
                patientName = replace(patientName, "SIM_" => "", count = 1)
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
            JavaCallHelper.loadPatientStruct(Patient, path *"\\"* patientName *"\\"* patientName *".PatientStruct")
            Patient.GoalFeed = Patient.Po
            Patient.hourlyBG = [0.0]
            #TimeSoln
            timeSoln = Simulation_Structs.TimeSoln()
            if ispath(path *"\\"* patientName *"\\"* patientName *".TimeSoln")
                JavaCallHelper.loadTimeSoln(timeSoln, path *"\\"* patientName *"\\"* patientName *".TimeSoln")
                dense_GIQ = timeSoln.GIQ
                Patient.GIQ = createGIQ(Patient.Greal, dense_GIQ)
            else
                Patient.GIQ = [0 0 0]
            end
            Patient.Greal_orig = [0.0]
            Patient.Treal_orig = [0.0]
            
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