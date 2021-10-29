module Serializer

    include("$(pwd())//src//JavaCall//JavaCallHelper.jl")
    include("$(pwd())//src//JavaCall//setup_java_libraries.jl")
    include("$(pwd())//src//Simulator//Simulation_Structs.jl")
    include("Resampler.jl")
    using JLD2
    using FileIO
    using MAT
    using .Simulation_Structs
    using .JavaCallHelper
    using .Resampler

    export SerializablePatient, serialize, deserialize

    mutable struct SerializablePatient
        Treal::Vector{Float64}
        Greal::Vector{Float64}
        TimeSolnGIQ::Matrix{Float64}
        TimeSolnT::Vector{Float64}
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
         "TimeSolnGIQ" => serPatient.TimeSolnGIQ,
         "TimeSolnT" => serPatient.TimeSolnT,
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

        type = splitext(readdir(path)[1])[2]

        if type == ".jld2" 
            return deserialize_jul(path, patientName)
        elseif type == ".mat" 
            return deserialize_mat(path, patientName)
        elseif type == "" 
            return deserialize_java(path, patientName)
        else
            throw(ArgumentError("Not existing serializable type."))
        end
        
    end

    function deserialize_jul(path, patientName)
        Patient = SerializablePatient()

        patientName = replace(patientName, "SIM_" => "", count = 1)
        data = load(path * "\\$patientName" * ".jld2") # it returns a Dictionary
            
        Patient.Treal = data["Treal"]
        Patient.Greal = data["Greal"]
        dense_GIQ = data["TimeSolnGIQ"]
        dense_T = data["TimeSolnT"]
        Patient.TimeSolnGIQ = Resampler.createGIQ(Patient.Treal, dense_T, dense_GIQ)
        Patient.P = data["P"]
        Patient.PN = data["PN"]
        Patient.rawSI = data["rawSI"]
        Patient.u = data["u"]
        Patient.hourlyBG = Resampler.resampleHourlyBG(dense_T, dense_GIQ)
        Patient.Name = data["Name"]
        Patient.GoalFeed = data["GoalFeed"]
        Patient.Po = data["Po"]
        Patient.Uo = data["Uo"]
        Patient.Treal_orig = data["Treal_orig"]
        Patient.Greal_orig = data["Greal_orig"]

        return Patient
    end

    function deserialize_mat(path, patientName)
        Patient = SerializablePatient()

        vars = undef
        if ispath(path * "\\$patientName" * ".mat")
            vars = matread(path * "\\$patientName" * ".mat")
        else 
            vars = matread(path * "\\SIM_$patientName" * ".mat")
            patientName = "SIM_$patientName"
        end

        Patient.Greal = vec(vars["PatientStruct"]["Greal"])
        Patient.Treal = vec(vars["PatientStruct"]["Treal"])
        Patient.Uo = vars["PatientStruct"]["Uo"]
        Patient.Po = vars["PatientStruct"]["Po"]
        Patient.Greal_orig = [0.0]
        Patient.Treal_orig = [0.0]
        
        if contains(patientName, "SIM_") # simulated values
            patientName = replace(patientName, "SIM_" => "", count = 1)
            dense_GIQ = vars["TimeSoln"]["GIQ"]
            dense_T = vec(vars["TimeSoln"]["T"])
            Patient.TimeSolnGIQ = Resampler.createGIQ(Patient.Treal, dense_T, dense_GIQ)
            Patient.hourlyBG = Resampler.resampleHourlyBG(dense_T, dense_GIQ)
            Patient.GoalFeed = vars["PatientStruct"]["GoalFeed"]
            Patient.P = [ vars["PatientStruct"]["P"][1] vars["PatientStruct"]["P"][2] ]
            Patient.PN = [ vars["PatientStruct"]["PN"][1] vars["PatientStruct"]["PN"][2] ]
            Patient.u = [ vars["PatientStruct"]["u"][1] vars["PatientStruct"]["u"][2] ]
            Patient.rawSI = [ vars["PatientStruct"]["rawSI"][1] vars["PatientStruct"]["rawSI"][2] ]
        else
            Patient.TimeSolnGIQ = [Patient.Greal zeros(length(Patient.Greal)) zeros(length(Patient.Greal))]
            Patient.hourlyBG = [0.0]
            Patient.GoalFeed = Patient.Po
            Patient.P = vars["PatientStruct"]["P"]
            Patient.PN = vars["PatientStruct"]["PN"]
            Patient.u =  vars["PatientStruct"]["u"]
            Patient.rawSI = vars["PatientStruct"]["rawSI"]
        end
        Patient.Name = patientName

        return Patient
    end

    function deserialize_java(path, patientName)
        Patient = SerializablePatient()

        setup_java_libraries()
        #PatientStruct
        JavaCallHelper.loadPatientStruct(Patient, path *"\\"* patientName *"\\"* patientName *".PatientStruct")
        Patient.GoalFeed = Patient.Po
        
        #TimeSoln
        timeSoln = Simulation_Structs.TimeSoln()
        if ispath(path *"\\"* patientName *"\\"* patientName *".TimeSoln")
            JavaCallHelper.loadTimeSoln(timeSoln, path *"\\"* patientName *"\\"* patientName *".TimeSoln")
            dense_GIQ = timeSoln.GIQ
            dense_T = timeSoln.T
            Patient.TimeSolnGIQ = Resampler.createGIQ(Patient.Treal, dense_T, dense_GIQ)
            Patient.hourlyBG = Resampler.resampleHourlyBG(dense_T, dense_GIQ)
        else
            Patient.TimeSolnGIQ = [0 0 0]
            Patient.hourlyBG = [0.0]
        end
        Patient.Greal_orig = [0.0]
        Patient.Treal_orig = [0.0]
        Patient.Name = patientName

        return Patient
    end

end