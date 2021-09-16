include("javaCallHelper.jl")
include("JavaClasses.jl")


function loadPatientData(patient, fullpath)

    #J_PatientStruct = J_PatientStruct_class(())
    J_PatientStruct = jcall(J_PatientStruct_class, "loadFromFile", J_PatientStruct_class, (JString,), fullpath)
   
    patient.Treal = jfield(J_PatientStruct, "Treal", Array{jdouble, 1})
    patient.Greal = jfield(J_PatientStruct, "Greal", Array{jdouble, 1})
    patient.u = jfield(J_PatientStruct, "u", Array{jdouble, 2})
    patient.P = jfield(J_PatientStruct, "P", Array{jdouble, 2})
    patient.PN = jfield(J_PatientStruct, "PN", Array{jdouble, 2})
    patient.Uo = jfield(J_PatientStruct, "Uo", jdouble)
    patient.Po = jfield(J_PatientStruct, "Po", jdouble)
    patient.DiabeticStatus = jfield(J_PatientStruct, "DiabeticStatus", jint)
    patient.rawSI = jfield(J_PatientStruct, "rawSI", Array{jdouble, 2})
    patient.weight = jfield(J_PatientStruct, "weight", jdouble)
    

end

function loadGUIData(guiData, fullpath)

    J_GUIData = J_GUIData_class(())
    J_GUIData = jcall(J_GUIData, "loadFromFilename", J_GUIData_class, (JString,), fullpath)
    
    guiData.Age = convert(Float64, jfield(J_GUIData, "Age", J_Double))
    guiData.Gender = convert(String, jfield(J_GUIData, "Gender", JString))
    guiData.Weight = convert(Float64, jfield(J_GUIData, "Weight", J_Double))
    guiData.FrameSize = convert(String, jfield(J_GUIData, "FrameSize", JString))
    guiData.DefaultInsulinConc = convert(Float64, jfield(J_GUIData, "DefaultInsulinConc", J_Double))
    guiData.DiabeticStatus = convert(Int32, jfield(J_GUIData, "DiabeticStatus", J_Integer))

    startTime =  jfield(J_GUIData, "StartTime", J_DateTime)
    guiData.StartTime = convertToJuliaDateTime(startTime)

    guiData.TargetRange = []
    J_targetRangeArray = jfield(J_GUIData, "TargetRange", J_ArrayList)
    size = jcall(J_targetRangeArray, "size", jint, ())
    for i in 1:size
        J_targetRange =convert(J_TargetRangeData_class, jcall(J_targetRangeArray, "get", JObject, (jint,), i-1))
        d = convertToJuliaDateTime( jfield(J_targetRange, "date", J_DateTime) )
        tLower = jfield(J_targetRange, "targetLower", jdouble)
        tUpper = jfield(J_targetRange, "targetUpper", jdouble)
        T = TargetRangeData()
        T.date = d
        T.targetLower = tLower
        T.targetUpper = tUpper
        push!(guiData.TargetRange, T)
    end
    
end

function printPatientData(patient)
    println("Patient's data from STAR: ")
    #println("CNS:\n", patient.CNS)
    println("Diabetic Status:\n ", patient.DiabeticStatus)
    println("EGP:\n", patient.EGP)
    #println("Treal:\n ", patient.Treal)
    #println("Greal:\n ", patient.Greal)
    #println("u:\n ", patient.u)
    #println("P:\n ", patient.P)
    #println("PN:\n ", patient.PN)
    println("Uo:\n ", patient.Uo)
    println("Po:\n ", patient.Po)
    println("Pmax:\n ", patient.Pmax)
    #println("rawSI:\n ", patient.rawSI)
    println("weight:\n ", patient.weight)
    #println("ControllerFlag:\n", patient.ControllerFlag)
    println()
end


function printGUIData(guiData)
    println("GUIData from STAR: ")
    println("start time:\n", guiData.StartTime)
    println("age:\n", guiData.Age)
    println("gender:\n", guiData.Gender)
    println("frame size:\n", guiData.FrameSize)
    println("weight:\n", guiData.Weight)
    println("TargetRange:\n ", guiData.TargetRange)
    println("Diabetic Status:\n", guiData.DiabeticStatus)

    println()
end

function printTimeSolnData(timeSoln)
    println("TimeSoln data from STAR: ")
    println("T:\n ", timeSoln.T)
    println("GIQ:\n ", timeSoln.GIQ)
    println("P:\n ", timeSoln.P)
    println()
end


function loadStochasticModelData(fullpath)
    return J_StochasticModel((JString,), fullpath)
end

function printStochasticData(stochastic)
    println("Stochastic Model Data: ")
    println(jfield(stochastic, "SI_5th_1hr", Array{jdouble, 1}))

    println()
end

