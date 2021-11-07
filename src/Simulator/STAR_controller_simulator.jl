include("$(pwd())\\src\\JavaCall\\JavaCallHelper.jl")
include("$(pwd())\\src\\JavaCall\\JavaClasses.jl")

using .JavaCallHelper

function STAR_controller_simulator(patient, simulation)
    
    TargetLower = 4.4
    TargetUpper = 8.0

    if length(patient.Treal) == 1
        println("### STAR_controller_simulator ###")
        patient.StochasticModel = JavaCallHelper.loadStochasticModelData( pwd() * "/src/JavaCall/SPRINT_whole_cohort.StochasticModel" );
        
        patient.guiData = J_GUIData_class(());
        JavaCallHelper.setAge(patient.guiData, 65.0);
        JavaCallHelper.setFrameSize(patient.guiData, "medium");
        JavaCallHelper.setGender(patient.guiData, "male");
        JavaCallHelper.setWeight(patient.guiData, 120.0) 
        now_time = J_DateTime(());
        JavaCallHelper.setStartTime(patient.guiData, now_time);

        b = J_BGData_class(());
        JavaCallHelper.setDate(b, now_time);
        JavaCallHelper.setBg(b, patient.Greal[1]);
        JavaCallHelper.addBg(patient.guiData, b);

        tr = J_TargetRangeData_class((J_DateTime, jdouble, jdouble), now_time, TargetLower, TargetUpper);
        JavaCallHelper.addTargetRange(patient.guiData, tr);

        JavaCallHelper.setDefaultInsulinConc(patient.guiData, 1.0);

        i = J_InsulinInfusionData_class(());
        JavaCallHelper.setDate(i, now_time);
        JavaCallHelper.setType(i, J_InsulinDetail(()));
        JavaCallHelper.setRate(i, patient.u[1,2] * 60.0 / 1000.0 / JavaCallHelper.getDefaultInsulinConc(patient.guiData) );
        JavaCallHelper.addInsulinInfusionIv(patient.guiData, i);

        # All enteral nutrition will be Glucerna
        n = J_NutritionData_class(());
        JavaCallHelper.setDate(n, now_time);
        nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("Glucerna"), 82.1, 1.0, -1.0, -1.0);
        JavaCallHelper.setType(n, nd);
        nRate = patient.P[1,2] * 60.0 * 180.0 / JavaCallHelper.getCarbs_conc(n);
        JavaCallHelper.setRate(n, nRate);
        JavaCallHelper.setFixed(n, UInt8(0));

        JavaCallHelper.addNutritionInfusionEnteral(patient.guiData, n);
        patient.P_prior = nRate;

        g = J_ControllerGoalData_class(());
        JavaCallHelper.setDate(g, now_time);
        JavaCallHelper.setGoal(g, "{C},false,8.0,100,100,30,5,180,60");
        JavaCallHelper.addControllerGoal(patient.guiData, g);

        # Store SPRINT's goal feed for the STAR controller to use
        gf = J_ControllerGoalData_class(());
        JavaCallHelper.setDate(gf, now_time);
        JavaCallHelper.setGoal(gf, "{T},$(nRate),0.0");
        patient.GoalFeed = nRate * JavaCallHelper.getCarbs_conc(n) / 60.0 / 180.0;
        JavaCallHelper.addControllerGoal(patient.guiData, gf);
        

        # All parenteral nutrition will be 12.5% dextrose
        for i in 1:length(patient.PN[1])
            n = J_NutritionData_class(());
            JavaCallHelper.setDate(n, JavaCallHelper.plusMinutes(now_time, patient.PN[i,1]) );
            nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("TPN pre-mix: 12.5% dextrose"), 125.0, 1.0, -1.0, -1.0);
            JavaCallHelper.setType(n, nd);
            JavaCallHelper.setRate(n, patient.PN[i, 2] * 60.0 * 180.0 / JavaCallHelper.getCarbs_conc(n));
            JavaCallHelper.setFixed(n, UInt8(1));
            JavaCallHelper.addNutritionInfusionParenteral(patient.guiData, n);
        end

        patient.patient = J_PatientStruct_class(());
        patient.patient = JavaCallHelper.UpdateRates(patient.guiData, patient.patient);
        JavaCallHelper.setU0(patient.patient, JavaCallHelper.getU(patient.patient)[1,2]);
        JavaCallHelper.setP0(patient.patient, JavaCallHelper.getP(patient.patient)[1,2]);
        JavaCallHelper.setDiabeticStatus(patient.patient, Int32(patient.Diabetic)); 

        # Initialise PatientStruct
        ICING2 = J_ICING2((J_GUIData_class, J_PatientStruct_class,), patient.guiData, patient.patient);
        o = JavaCallHelper.model_fit_init(ICING2, patient.patient);
        patient.patient = JavaCallHelper.getPatient(o);
        patient.TimeSoln = JavaCallHelper.getTimeSoln(o);

        time = now_time;
        patient.StoppedFeed = 0;
        patient.nrBg = 1;
        
    else
        
        # Add the latest BG to GUIData
        b = J_BGData_class(());
        JavaCallHelper.setDate(b, JavaCallHelper.plusMinutes( JavaCallHelper.getStartTime(patient.guiData), patient.Treal[end]));
        JavaCallHelper.setBg(b, patient.Greal[end]);
        JavaCallHelper.addBg(patient.guiData, b);

        # Update PatientStruct
        patient.patient = JavaCallHelper.UpdateRates(patient.guiData, patient.patient);

        time = JavaCallHelper.getDate(b);

        patient.nrBg += 1;
        
    end

    # Implement clinial feed stoppages
    # Next P_orig switch off or on
    stopped_limit = 3;
    t_now = patient.Treal[end];
    current_P_orig_index = findlast(x -> x <= t_now, patient.P_orig[:,1]);
    if isnothing(current_P_orig_index)  current_P_orig_index = 1 end
    current_P_orig = patient.P_orig[current_P_orig_index, 2];

    # Time to feed switched off
    next_P_orig_index = 0;
    for i in 1:size(patient.P_orig, 1)
        if patient.P_orig[i,1] > t_now && patient.P_orig[i,2] == 0
            next_P_orig_index = i;
            break;
        end
    end

    if next_P_orig_index != 0
        stopped_limit = min(3, (patient.P_orig[next_P_orig_index, 1] - t_now) / 60.0 );
    end


    if current_P_orig == 0
        patient.StoppedFeed = 1;
        # Time to restart
        next_P_orig_index = 0;
        for i in 1:size(patient.P_orig, 1)
            if patient.P_orig[i,1] > t_now && patient.P_orig[i,2] > 0
                next_P_orig_index = i;
                break;
            end
        end

        if next_P_orig_index != 0
            patient.RestartRate = patient.P_orig[next_P_orig_index, 2] * patient.GoalFeed / 100.0 ;
        else
            next_P_orig_index = 1;
        end
        
        stopped_limit = min(2, (patient.P_orig[next_P_orig_index, 1] - t_now) / 2.0);

        n = J_NutritionData_class(());
        JavaCallHelper.setDate(n, time);
        nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("Glucerna"), 81.2, 1.0, -1.0, -1.0);
        JavaCallHelper.setType(n, nd);
        JavaCallHelper.setRate(n, 0.0);
        JavaCallHelper.setFixed(n, UInt8(1));
        JavaCallHelper.addNutritionInfusionEnteral(patient.guiData, n);
       
    elseif patient.StoppedFeed == 1
        # Restarts feed at clinically chosen rate
        patient.StoppedFeed = 0;

        n = J_NutritionData_class(());
        JavaCallHelper.setDate(n, time);
        nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("Glucerna"), 81.2, 1.0, -1.0, -1.0);
        JavaCallHelper.setType(n, nd);
        JavaCallHelper.setRate(n, patient.RestartRate * 60.0 * 180.0 / JavaCallHelper.getCarbs_conc(n));
        JavaCallHelper.setFixed(n, UInt8(0));
        JavaCallHelper.addNutritionInfusionEnteral(patient.guiData, n);
       
    else
        patient.StoppedFeed = 0;
    end

    # Update the stochastic model data
    patient.StochasticModel = JavaCallHelper.loadStochasticModelData( pwd() * "/src/JavaCall/SPRINT_whole_cohort.StochasticModel" );
    
    BGList = JavaCallHelper.getBGList(patient.guiData);

    legacyBg = convert(J_BGData_class, JavaCallHelper.getByIndex(BGList, JavaCallHelper.getListSize(BGList) - 1));
    actualBG = JavaCallHelper.getBg(legacyBg)
    println("calculating treatments for (nr = ", patient.nrBg, "): ",JavaCallHelper.convertToJuliaDateTime(JavaCallHelper.getDate(legacyBg)) ,", BG = ", round(actualBG, digits=6), " ...");

    
    # Run the STAR controller
    patient.patient = JavaCallHelper.UpdateRates(patient.guiData, patient.patient);
    STAR_controller = J_STAR_controller(());
    controller_output = JavaCallHelper.runController(STAR_controller, patient.patient, patient.guiData, patient.TimeSoln, patient.StochasticModel);
    # Select a treatment option (longest allowed option is defined by
    # longest_allowed at top of control script)
    max_available = 3;
    if isnull(controller_output[3])
        max_available = 2;
    end
    if isnull(controller_output[2])
        max_available = 1;
    end

    selection = Int32(min(max_available, simulation.longest_allowed, max(1, round(stopped_limit))));
   
    # Store chosen treatment in GUIData
    # Taken from RecommendationActivity.selectTreatment(...)
    isFirstTreatment = 1
    if length(patient.Treal) == 1
        isFirstTreatment = 1;
    else
        isFirstTreatment = 0;
    end

    if ! isnull(JavaCallHelper.getInsulinBolus(controller_output[selection]))
        JavaCallHelper.addInsulinBolusIv(patient.guiData, JavaCallHelper.getInsulinBolus(controller_output[selection]));
    end

    fb = JavaCallHelper.getFutureBolus(controller_output[selection]);
    if ! isnull(fb)
        len = getListSize(fb);
        for i in 1:len
            bolus = convert(J_InsulinBolusData_class, JavaCallHelper.getByIndex(fb, i));
            JavaCallHelper.addInsulinBolusIv(patient.guiData, bolus);
        end
    end

    if ! isnull(JavaCallHelper.getInsulinInfusion(controller_output[selection]))
        if isFirstTreatment == 1 
            JavaCallHelper.clearInsulinInfusionIvList(patient.guiData);
        end
        JavaCallHelper.addInsulinInfusionIv(patient.guiData, JavaCallHelper.getInsulinInfusion(controller_output[selection]));
    end

    if ! isnull(JavaCallHelper.getEnteral(controller_output[selection]))
        if isFirstTreatment == 1 
            JavaCallHelper.clearNutritionInfusionEnteral(patient.guiData);
        end
        JavaCallHelper.addNutritionInfusionEnteral(patient.guiData, JavaCallHelper.getEnteral(controller_output[selection]));
    end
    

    if ! isnull(JavaCallHelper.getParenteral(controller_output[selection]))
        JavaCallHelper.addNutritionInfusionParenteral(patient.guiData, JavaCallHelper.getParenteral(controller_output[selection]));
    end

    if ! isnull(JavaCallHelper.getMaintenance(controller_output[selection]))
        JavaCallHelper.addNutritionInfusionMaintenance(patient.guiData, JavaCallHelper.getMaintenance(controller_output[selection]));
    end

    if ! isnull(JavaCallHelper.getDextroseShot(controller_output[selection]))
        JavaCallHelper.addNutritionBolusDexShot(patient.guiData, JavaCallHelper.getDextroseShot(controller_output[selection]));
    end

    push!(patient.ControllerFlag, JavaCallHelper.getControllerFlag(controller_output[selection]));

    patient.patient = JavaCallHelper.UpdateRates(patient.guiData, patient.patient);

    patient.u = JavaCallHelper.getU(patient.patient);
    patient.P = JavaCallHelper.getP(patient.patient);
    patient.PN = JavaCallHelper.getPN(patient.patient);

    if simulation.protocol_timing == 1
        simulation.measurement_time = selection * 60.0;
    end

    if simulation.protocol_timing == 2
        i = findlast(t -> t <= patient.Treal[end], patient.Treal_orig)
        if i < length(patient.Treal_orig)
            simulation.measurement_time = patient.Treal_orig[i+1] - patient.Treal_orig[i]
        else
            simulation.measurement_time = selection * 60.0;
        end
    end

    if patient.Treal[end] >= patient.rawSI[end, 1]
        simulation.stop_simulation = 1;
    end

end