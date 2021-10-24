module JavaCallHelper

include("JavaClasses.jl")
using Dates
using JavaCall

function convertToJuliaDateTime(J_dateTime::J_DateTime)
    year = jcall(J_dateTime, "getYear", jint, ());
    month = jcall(J_dateTime, "getMonthOfYear", jint, ());
    day = jcall(J_dateTime, "getDayOfMonth", jint, ());
    hour = jcall(J_dateTime, "getHourOfDay", jint, ());
    minute = jcall(J_dateTime, "getMinuteOfHour", jint, ());
    second = jcall(J_dateTime, "getSecondOfMinute", jint, ());
    return DateTime(year, month, day, hour, minute, second);
end

function convertToJavaDateTime(dateTime::DateTime)
    return  J_DateTime((jint, jint, jint, jint, jint, jint, jint), 
            Dates.year(dateTime),  Dates.month(dateTime),  Dates.day(dateTime),
            Dates.hour(dateTime),  Dates.minute(dateTime),  Dates.second(dateTime),  Dates.millisecond(dateTime));
end

#------- ArrayList -------#

function getListSize(List::J_ArrayList)
    return jcall(List, "size", jint, ());
end

function getByIndex(list::J_ArrayList, index)
    return  jcall(list, "get", JObject, (jint,), convert(jint, index));
end

#------- DateTime -------#

function plusMinutes(dateTime::J_DateTime, min::Float64)
    min = Int64(round(min));
    jcall(dateTime, "plusMinutes", J_DateTime, (jint,), min);
end

#------- GUIData -------#

function setWeight(guiData::J_GUIData_class, weight::jdouble)
    jcall(guiData, "setWeight", Nothing, (jdouble,), weight);
end

function setAge(guiData::J_GUIData_class, age::jdouble)
    jcall(guiData, "setAge", Nothing, (jdouble,), age);
end

function setGender(guiData::J_GUIData_class, gender::String)
    jcall(guiData, "setGender", Nothing, (JString,), JString(gender));
end

function setFrameSize(guiData::J_GUIData_class, frameSize::String)
    jcall(guiData, "setFrameSize", Nothing, (JString,), JString(frameSize));
end

function setStartTime(guiData::J_GUIData_class, startTime::J_DateTime)
    jcall(guiData, "setStartTime", Nothing, (J_DateTime,), startTime );
end

function getStartTime(guiData::J_GUIData_class)
    return jfield(guiData, "StartTime", J_DateTime);
end

function setDefaultInsulinConc(guiData::J_GUIData_class, i::jdouble)
    jcall(guiData, "setDefaultInsulinConc", Nothing, (jdouble,), i);
end

function addBg(guiData::J_GUIData_class, BG::J_BGData_class)
    jcall(guiData, "addBg", Nothing, (J_BGData_class,), BG);
end

function  addTargetRange(guiData::J_GUIData_class, tr::J_TargetRangeData_class)
    jcall(guiData, "addTargetRange", Nothing, (J_TargetRangeData_class,), tr);
end

function addInsulinInfusionIv(guiData::J_GUIData_class, iv::J_InsulinInfusionData_class)
    jcall(guiData, "addInsulinInfusionIv", Nothing, (J_InsulinInfusionData_class,), iv);
end

function addNutritionInfusionEnteral(guiData::J_GUIData_class, n::J_NutritionData_class)
    jcall(guiData, "addNutritionInfusionEnteral", Nothing, (J_NutritionData_class,), n);
end

function addNutritionInfusionParenteral(guiData::J_GUIData_class, n::J_NutritionData_class)
    jcall(guiData, "addNutritionInfusionParenteral", Nothing, (J_NutritionData_class,), n);
end

function addControllerGoal(guiData::J_GUIData_class, g::J_ControllerGoalData_class)
    jcall(guiData, "addControllerGoal", Nothing, (J_ControllerGoalData_class,), g);
end

function addInsulinBolusIv(guiData::J_GUIData_class, ib::J_InsulinBolusData_class)
    jcall(guiData, "addInsulinBolusIv", Nothing, (J_InsulinBolusData_class,), ib);
end

function addNutritionInfusionMaintenance(guiData::J_GUIData_class, ni::J_NutritionData_class)
    jcall(guiData, "addNutritionInfusionMaintenance", Nothing, (J_NutritionData_class,), ni);
end

function addNutritionBolusDexShot(guiData::J_GUIData_class, dexShot::J_NutritionBolusData_class)
    jcall(guiData, "addNutritionBolusDexShot", Nothing, (J_NutritionBolusData_class,), dexShot)
end

function getDefaultInsulinConc(guiData::J_GUIData_class)
    return convert(Float64, jfield(guiData, "DefaultInsulinConc", J_Double));
end

function getBGList(guiData::J_GUIData_class)
    return  jfield(guiData, "BG", J_ArrayList);
end

function getInsulinInfusion(guiData::J_GUIData_class)
    return jfield(guiData, "InsulinInfusion", J_ArrayList);
end

function getNutritionInfusion(guiData::J_GUIData_class)
    return jfield(guiData, "NutritionInfusion", J_ArrayList);
end

function clearInsulinInfusionIvList(guiData::J_GUIData_class)
    jcall(guiData, "clearInsulinInfusionIvList", Nothing, ());
end

function clearNutritionInfusionEnteral(guiData::J_GUIData_class)
    jcall(guiData, "clearNutritionInfusionEnteral", Nothing, ());
end

#=
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
        T.date = d
        T.targetLower = tLower
        T.targetUpper = tUpper
        push!(guiData.TargetRange, T)
    end
    
end
=#

#------- BGData_class -------#

function setDate(BG::J_BGData_class, dateTime::J_DateTime)
    jcall(BG, "setDate", Nothing, (J_DateTime,), dateTime);
end

function getDate(BG::J_BGData_class)
    return jfield(BG, "date", J_DateTime);
end

function setBg(BG::J_BGData_class, bg::jdouble)
    jcall(BG, "setBg", Nothing, (jdouble,), bg);
end

function getBg(BG::J_BGData_class)
    return jfield(BG, "BG", jdouble);
end

#------- InsulinInfusionData_class -------#

function setDate(I::J_InsulinInfusionData_class, dateTime::J_DateTime)
    jcall(I, "setDate", Nothing, (J_DateTime,), dateTime);
end

function setType(I::J_InsulinInfusionData_class, i::J_InsulinDetail)
    jcall(I, "setType", Nothing, (J_InsulinDetail,), i);
end

function setRate(I::J_InsulinInfusionData_class, r::jdouble)
    jcall(I, "setRate", Nothing, (jdouble,), r);
end

#------- NutritionData_class -------#

function setDate(N::J_NutritionData_class, dateTime::J_DateTime)
    jcall(N, "setDate", Nothing, (J_DateTime,), dateTime);
end

function setType(N::J_NutritionData_class, nd::J_NutritionDetail)
    jcall(N, "setType", Nothing, (J_NutritionDetail,), nd);
end

function setRate(N::J_NutritionData_class, r::jdouble)
    jcall(N, "setRate", Nothing, (jdouble,), r);
end

function setFixed(N::J_NutritionData_class, f::jboolean)
    jcall(N, "setFixed", Nothing, (jboolean,), f);
end

function getCarbs_conc(N::J_NutritionData_class)
    nd = jcall(N, "getType", J_NutritionDetail, ());
    return jfield(nd, "carbs_conc", jdouble);
end

function getRate(N::J_NutritionData_class)
    return jfield(N, "rate", jdouble);
end

#------- ControllerGoalData_class -------#

function setDate(CG::J_ControllerGoalData_class, dateTime::J_DateTime)
    jcall(CG, "setDate", Nothing, (J_DateTime,), dateTime);
end

function setGoal(CG::J_ControllerGoalData_class, g::String)
    jcall(CG, "setGoal", Nothing, (JString,), JString(g));
end

#------- SweetInterface -------#

function UpdateRates(guiData::J_GUIData_class, patient::J_PatientStruct_class)
    return jcall(J_SweetInterface, "UpdateRates", J_PatientStruct_class, (J_GUIData_class, J_PatientStruct_class,), guiData, patient);
end

#------- PatientStruct_class -------#

function getU(patient::J_PatientStruct_class)
    return convert(Array{Float64, 2}, jfield(patient, "u", Array{jdouble, 2}));
end

function getP(patient::J_PatientStruct_class)
    return convert(Array{Float64, 2}, jfield(patient, "P", Array{jdouble, 2}));
end

function getPN(patient::J_PatientStruct_class)
    return convert(Array{Float64, 2}, jfield(patient, "PN", Array{jdouble, 2}));
end

function setU0(patient::J_PatientStruct_class, u0::jdouble)
    jcall(patient, "setU0", Nothing, (jdouble,), u0);
end

function setP0(patient::J_PatientStruct_class, p0::jdouble)
    jcall(patient, "setP0", Nothing, (jdouble,), p0);
end

function setDiabeticStatus(patient::J_PatientStruct_class, ds::jint)
    jcall(patient, "setDiabeticStatus", Nothing, (jint,), ds);
end

function loadPatientStruct(patient, fullpath)
    J_PatientStruct = jcall(J_PatientStruct_class, "loadFromFile", J_PatientStruct_class, (JString,), fullpath)
    patient.Treal = jfield(J_PatientStruct, "Treal", Array{jdouble, 1})
    patient.Greal = jfield(J_PatientStruct, "Greal", Array{jdouble, 1})
    patient.u = jfield(J_PatientStruct, "u", Array{jdouble, 2})
    patient.P = jfield(J_PatientStruct, "P", Array{jdouble, 2})
    patient.PN = jfield(J_PatientStruct, "PN", Array{jdouble, 2})
    patient.Uo = jfield(J_PatientStruct, "Uo", jdouble)
    patient.Po = jfield(J_PatientStruct, "Po", jdouble)
    patient.rawSI = jfield(J_PatientStruct, "rawSI", Array{jdouble, 2})
end

#------- ICING2 -------#

function model_fit_init(ICING2::J_ICING2, patient::J_PatientStruct_class)
    return jcall(ICING2, "model_fit_init", J_Sweet_outputs_fit_init, (J_PatientStruct_class,), patient);
end

function getPatient(o::J_Sweet_outputs_fit_init)
    return jfield(o, "PatientStruct", J_PatientStruct_class);
end

function getTimeSoln(o::J_Sweet_outputs_fit_init)
    return jfield(o, "TimeSoln", J_TimeSoln_class);
end

# ------- STAR_controller -------#

function runController(controller::J_STAR_controller, patient::J_PatientStruct_class,
        guiData::J_GUIData_class, timeSoln::J_TimeSoln_class, stochasticModel::J_StochasticModel)
    return jcall(controller, "runController", Array{J_SweetInterface_Controller_outputs, 1},
     (J_PatientStruct_class, J_GUIData_class, J_TimeSoln_class, J_StochasticModel), patient, guiData, timeSoln, stochasticModel);
end

# ------- Controller_outputs -------#

function getInsulinBolus(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "InsulinBolus", J_InsulinBolusData_class);
end

function getFutureBolus(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "FutureBolus", J_ArrayList);
end

function getInsulinInfusion(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "InsulinInfusion", J_InsulinInfusionData_class);
end

function getEnteral(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "Enteral", J_NutritionData_class);
end

function getParenteral(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "Parenteral", J_NutritionData_class);
end

function getMaintenance(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "Maintenance", J_NutritionData_class);
end

function getDextroseShot(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "DextroseShot", J_NutritionBolusData_class);
end

function getControllerFlag(sc::J_SweetInterface_Controller_outputs)
    return jfield(sc, "controllerFlag", jint);
end

# ----- J_TimeSoln_class ----- #

function loadTimeSoln(timeSoln, fullpath)

    J_TimeSoln = jcall(J_TimeSoln_class, "loadFromFile", J_TimeSoln_class, (JString,), fullpath)
    timeSoln.GIQ = jfield(J_TimeSoln, "GIQ", Array{jdouble, 2})
    timeSoln.T = jfield(J_TimeSoln, "T", Array{jdouble, 1})
    timeSoln.P = jfield(J_TimeSoln, "P", Array{jdouble, 2})

end

# ----- J_StochasticModel ----- #

function loadStochasticModelData(fullpath)
    return J_StochasticModel((JString,), fullpath)
end



end # end module


