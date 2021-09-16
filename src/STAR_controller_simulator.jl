include("JavaCall\\javaCallHelper.jl")
include("JavaCall\\JavaClasses.jl")

function STAR_controller_simulator(patient, simulation)
   
    TargetLower = 80/18
    TargetUpper = 145/18
    longest_allowed = 3

    if (size(patient.Treal, 1) == 1)
        patient.StochasticModel = loadStochasticModelData( pwd() * "/src/SPRINT_whole_cohort.StochasticModel" );
        
        patient.guiData = J_GUIData_class(());
        setAge(patient.guiData, 65.0);
        setFrameSize(patient.guiData, "medium");
        setGender(patient.guiData, "male");
        now_time = J_DateTime(());
        setStartTime(patient.guiData, now_time);

        bg = J_BGData_class(());
        setDate(bg, now_time);
        setBg(bg, patient.Greal[1]);
        addBg(patient.guiData, bg);

        tr = J_TargetRangeData_class((J_DateTime, jdouble, jdouble), now_time, TargetLower, TargetUpper);
        addTargetRange(patient.guiData, tr);

        setDefaultInsulinConc(patient.guiData, 1.0);

        i = J_InsulinInfusionData_class(());
        setDate(i, now_time);
        setType(i, J_InsulinDetail(()));
        setRate(i, patient.u[1,2] * 60.0 / 1000.0 / getDefaultInsulinConc(patient.guiData) );
        addInsulinInfusionIv(patient.guiData, i);

        # All enteral nutrition will be Glucerna
        n = J_NutritionData_class(());
        setDate(n, now_time);
        nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("Glucerna"), 82.1, 1.0, -1.0, -1.0);
        setType(n, nd);
        nRate = patient.P[1,2] * 60.0 * 180.0 / getCarbs_conc(n);
        setRate(n, nRate);
        setFixed(n, UInt8(0));

        addNutritionInfusionEnteral(patient.guiData, n);
        patient.P_prior = nRate;

        g = J_ControllerGoalData_class(());
        setDate(g, now_time);
        setGoal(g, "{C},false,8.0,100,100,30,5,180,60");
        addControllerGoal(patient.guiData, g);

        # Store SPRINT's goal feed for the STAR controller to use
        gf = J_ControllerGoalData_class(());
        setDate(gf, now_time);
        setGoal(gf, "{T},$(nRate),0.0");
        patient.GoalFeed = nRate * getCarbs_conc(n) / 60.0 / 180.0;
        addControllerGoal(patient.guiData, gf);
        

        # All parenteral nutrition will be 12.5% dextrose
        for i in 1:size(patient.PN, 1)
            n = J_NutritionData_class(());
            setDate(n, plusMinutes(now_time, patient.PN[i,1]) );
            nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("TPN pre-mix: 12.5% dextrose"), 125.0, 1.0, -1.0, -1.0);
            setType(n, nd);
            setRate(n, patient.PN[i, 2] * 60.0 * 180.0 / getCarbs_conc(n));
            setFixed(n, UInt8(1));
            addNutritionInfusionParenteral(patient.guiData, n);
        end

        patient.patient = J_PatientStruct_class(());
        patient.patient = UpdateRates(patient.guiData, patient.patient);
        setU0(patient.patient, getU(patient.patient)[1,2]);
        setP0(patient.patient, getP(patient.patient)[1,2]);
        setDiabeticStatus(patient.patient, Int32(patient.Diabetic)); 

        # Initialise PatientStruct
        ICING2 = J_ICING2((J_GUIData_class, J_PatientStruct_class,), patient.guiData, patient.patient);
        o = model_fit_init(ICING2, patient.patient);
        patient.patient = getPatient(o);
        patient.TimeSoln = getTimeSoln(o);

        time = now_time;
        patient.StoppedFeed = 0;
        patient.nrBg = 1;
        
    else
        
        # Add the latest BG to GUIData
        b = J_BGData_class(());
        setDate(b, plusMinutes( getStartTime(patient.guiData), patient.Treal[end]));
        setBg(b, patient.Greal[end]);
        addBg(patient.guiData, b);

        # Update PatientStruct
        patient.patient = UpdateRates(patient.guiData, patient.patient);

        time = getDate(b);

        patient.nrBg += 1;
        
    end

    # Implement clinial feed stoppages
    # Next P_orig switch off or on
    stopped_limit = 3;
    t_now = patient.Treal[end];
    current_P_orig_index = findlast(x -> x <= t_now, patient.P_orig[:,1]);
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
        
        stopped_limit = min(2, (patient.P_orig[next_P_orig_index, 1] - t_now) / 2);

        n = J_NutritionData_class(());
        setDate(n, time);
        nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("Glucerna"), 81.2, 1.0, -1.0, -1.0);
        setType(n, nd);
        setRate(n, 0.0);
        setFixed(n, UInt8(1));
        addNutritionInfusionEnteral(patient.guiData, n);
       
    elseif patient.StoppedFeed == 1
        # Restarts feed at clinically chosen rate
        patient.StoppedFeed = 0;

        n = J_NutritionData_class(());
        setDate(n, time);
        nd = J_NutritionDetail((JString, jdouble, jdouble, jdouble, jdouble), JString("Glucerna"), 81.2, 1.0, -1.0, -1.0);
        setType(n, nd);
        setRate(n, patient.RestartRate * 60.0 * 180.0 / getCarbs_conc(n));
        setFixed(n, UInt8(0));
        addNutritionInfusionEnteral(patient.guiData, n);
       
    else
        patient.StoppedFeed = 0;
    end

    
    
    # Update the stochastic model data
    patient.StochasticModel = loadStochasticModelData( pwd() * "/src/SPRINT_whole_cohort.StochasticModel" );
    
    BGList = getBGList(patient.guiData);

    legacyBg = convert(J_BGData_class, getByIndex(BGList, getListSize(BGList) - 1));
    println("calculating treatments for (nr = ", patient.nrBg, "): ",convertToJuliaDateTime(getDate(legacyBg)) ,", BG = ", getBg(legacyBg), " ...");

    
    # Run the STAR controller
    patient.patient = UpdateRates(patient.guiData, patient.patient);
    STAR_controller = J_STAR_controller(());
    controller_output = runController(STAR_controller, patient.patient, patient.guiData, patient.TimeSoln, patient.StochasticModel);
    # Select a treatment option (longest allowed option is defined by
    # longest_allowed at top of control script)
    max_available = 3;
    if isnull(controller_output[3])
        max_available = 2;
    end
    if isnull(controller_output[2])
        max_available = 1;
    end

    selection = Int32(min(max_available, longest_allowed, max(1, round(stopped_limit))));
   
    # Store chosen treatment in GUIData
    # Taken from RecommendationActivity.selectTreatment(...)
    if size(patient.Treal, 1) == 1
        isFirstTreatment = 1;
    else
        isFirstTreatment = 0;
    end

    if ! isnull(getInsulinBolus(controller_output[selection]))
        addInsulinBolusIv(patient.guiData, getInsulinBolus(controller_output[selection]));
    end


    fb = getFutureBolus(controller_output[selection]);
    if ! isnull(fb)
        len = getListSize(fb);
        for i in 1:len
            bolus = convert(J_InsulinBolusData_class, getByIndex(fb, i));
            addInsulinBolusIv(patient.guiData, bolus);
        end
    end

    

    if ! isnull(getInsulinInfusion(controller_output[selection]))
        if isFirstTreatment == 1 && getListSize(convert(J_ArrayList, getByIndex( getInsulinInfusion(patient.guiData), 0))) > 0
            clearInsulinInfusionIvList(patient.guiData);
        end
        addInsulinInfusionIv(patient.guiData, getInsulinInfusion(controller_output[selection]));
    end

    

    if ! isnull(getEnteral(controller_output[selection]))
        if isFirstTreatment == 1 && getListSize(convert(J_ArrayList, getByIndex( getNutritionInfusion(patient.guiData), 0))) > 0
            clearNutritionInfusionEnteral(patient.guiData);
        end
        addNutritionInfusionEnteral(patient.guiData, getEnteral(controller_output[selection]));
    end
    

    if ! isnull(getParenteral(controller_output[selection]))
        addNutritionInfusionParenteral(patient.guiData, getParenteral(controller_output[selection]));
    end

    if ! isnull(getMaintenance(controller_output[selection]))
        addNutritionInfusionMaintenance(patient.guiData, getMaintenance(controller_output[selection]));
    end

    if ! isnull(getDextroseShot(controller_output[selection]))
        addNutritionBolusDexShot(patient.guiData, getDextroseShot(controller_output[selection]));
    end

    
    push!(patient.ControllerFlag,  getControllerFlag(controller_output[selection]));

    patient.patient = UpdateRates(patient.guiData, patient.patient);

    patient.u = getU(patient.patient);
    patient.P = getP(patient.patient);
    patient.PN = getPN(patient.patient);

    simulation.measurement_time = selection * 60.0;
    if patient.Treal[end] >= patient.rawSI[end, 1]
        simulation.stop_simulation = 1;
    end

end