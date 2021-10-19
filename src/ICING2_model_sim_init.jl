function ICING2_model_sim_init(patient, timeSoln, egp)
    
    patient.pG = 0.006;   #non-insulin mediated glucose removal parameter [1/min]
    patient.CNS = 0.3;    #Central nervous system glucose uptake
    patient.varEGP = false;
    patient.EGP = [0.0 , egp];
    patient.stochasticModelFileName = "SPRINT_whole_cohort.StochasticModel";

    patient.Diabetic = 0;

    
    patient.uenmin = 16.7; #[mU/min]
    patient.uenmax = 266.7; #[mU/min]
    patient.k1 = [14.9, 0.0, 4.9];    #[ND, T1DM, T2DM] 
    patient.k2 = [-49.9, 16.7, -27.4];    #[ND, T1DM, T2DM] 

    # Uen function for non-diabetic patients
    patient.Ueninit = min(max(patient.uenmin, (patient.k1[1]*patient.Greal[1]+patient.k2[1])), patient.uenmax);     # endogenous insulin production rate [mU/min] initial value - 1U/hr if below min and 16U/hr is above max
   
    patient.xl = 0.67; # First-pass liver extraction of insulin [Non Dim]
    patient.nI = 0.006; # diffusion rate between I and Q [1/min]
    patient.nC = patient.nI; # interstitial insulin degradation base rate [1/min]
    patient.nK = 0.0542; # kidney insulin clearance [1/min]
    patient.nL = 0.1578; # liver insulin clearance base rate [1/min]
    patient.d1 = -log(0.5)/20; # glucose transfer rate from stomach to gut [1/min]
    patient.d2 = -log(0.5)/100; # glucose transfer clearance rate from gut [1/min]
    patient.Vi = 4.0; # Plasma insulin distribution volume [L]
    patient.Vg = 13.3; # Plasma glucose distribution volume [L]
    patient.alpha_I = 0.0017; # insulin clearance saturation parameter [L/mU]
    patient.alpha_G = 1.0/65.0; # insulin binding saturation parameter [L/mU]
    patient.Pmax = 6.11;  # maximum glucose flux out of the gut [mmol/min]
    patient.gamma = patient.nI/(patient.nI+patient.nC);

    patient.ProtocolTiming = true;   # Whether to use protocol timing (true) or actual clinical timing for BG measurements (false)

    #Save a description of which BG model/solver was used
    patient.SolverMethod = "ICING2_model - ODE solver";

    #-------------------------------------------------------------------------------

    # Steady-state insulin levels
    # From setting Qdot = Idot = 0 and solving for I;
    Iss = (((1-patient.xl)*patient.Ueninit+patient.Uo)/patient.Vi)/(patient.nK+patient.nL+patient.nI*(1-patient.gamma)); # basal I [mU/L]
    IQ0 = [1,patient.gamma]*Iss; # I = 2Q at steady state

    #-------------------------------------------------------------------------------
        #Initialise TimeSoln
    timeSoln.T = [patient.Treal[1]];
    timeSoln.GIQ = [patient.Greal[1] IQ0[1] IQ0[2]] ;
    timeSoln.P = [patient.Po/patient.d1 patient.Po/patient.d2];
    #-------------------------------------------------------------------------------

    #Step 2: Set up initial conditions for the controller - clear out the
    #u variables, and remove the BG measurements
    patient.P_orig = patient.P;     #Save the retrospective feeding in case we want to simulate an insulin-only protocol
    patient.PN_orig = patient.PN;
    patient.Greal_orig = patient.Greal;
    patient.Treal_orig = patient.Treal;     #Save the retrospective measurement timings (useful for some simulation studies)

    patient.u = Array{Float64}(undef, 2, 2);
    patient.u[1,1] = patient.rawSI[1,1];
    patient.u[1,2] = patient.Uo;
    patient.u[2,1] = patient.u[1,1] + 1;
    patient.u[2,2] = patient.Uo;
    patient.P = Array{Float64}(undef, 1, 2);
    patient.P[1,1] = patient.rawSI[1,1];
    patient.P[1,2] = patient.Po;
    patient.PN = Array{Float64}(undef, 1, 2);
    patient.PN[1,1] = patient.rawSI[1,1];
    patient.PN[1,2] = 0.0;
    patient.PN[2,1] = patient.PN[1,1] + 5;
    patient.PN[2,2] = 0.0;

    patient.Treal = [patient.Treal[1]];     
        #Treal and Greal will store the virtual BG measurments taken during the simulated trial
    patient.Greal = [round(patient.Greal[1]*10)/10];  # 1dp
    patient.Ireal = [IQ0[1]]
    patient.Qreal = [IQ0[2]]
    #------start the simulation from the first recorded sI value
    #------...this *may* not necessarily be zero (especially if dealing
    #with a patient record that is split into several parts)

    start_time = patient.Treal[1];
    patient.ControllerFlag = [];
    patient.hourlyBG = [timeSoln.GIQ[1,1]];

end