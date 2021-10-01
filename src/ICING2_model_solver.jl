using OrdinaryDiffEq

function resampleHourlyBG(patient, timeSoln, t_start)
    if timeSoln.T[end]-60 > t_start
        i = findfirst(x -> x-60 > t_start, timeSoln.T)
        push!(patient.hourlyBG, timeSoln.GIQ[i,1])
    end
    if timeSoln.T[end]-120 > t_start
        i = findfirst(x -> x-120 > t_start, timeSoln.T)
        push!(patient.hourlyBG, timeSoln.GIQ[i,1])
    end
    push!(patient.hourlyBG, timeSoln.GIQ[end,1])
end

function ICING2_model_solver(patient, timeSoln, t_start, t_end)

    if t_start == t_end
        return
    end

    function ICING_model_ODE!(du, u, p, t)
        G, I, Q, P1, P2 = u;

        EGP = 1.16;

        i = findlast(x -> x <= t, patient.rawSI[:,1]);
        if isnothing(i)
            i = 1
        end
        SI = patient.rawSI[i, 2];
        
        i = findlast(x -> x <= t, patient.P[:,1]);
        if isnothing(i)
            i = 1
        end
        P = patient.P[i,2];

        i = findlast(x -> x <= t, patient.PN[:,1]);
        if isnothing(i)
            i = 1
        end
        PN = patient.PN[i,2];
       
        i = findlast(x -> x <= t, patient.u[:,1]);
        if isnothing(i)
            i = 1
        end
        u_ex = patient.u[i,2];
        
        u_en = min(max(patient.uenmin, (patient.k1[1]*G+patient.k2[1])), patient.uenmax);

        du[1] = -patient.pG*G - SI*G*Q/(1+patient.alpha_G*Q) + min(patient.d2*P2,patient.Pmax)/patient.Vg + EGP/patient.Vg - patient.CNS/patient.Vg + PN/patient.Vg;
        du[2] = -I*patient.nK - I*patient.nL/(1+I*patient.alpha_I) - (I-Q)*patient.nI + u_ex/patient.Vi + (1-patient.xl)*u_en/patient.Vi;
        du[3] = (I-Q)*patient.nI - Q*patient.nC/(1+Q*patient.alpha_G);
        du[4] = -patient.d1 * P1 + P;
        du[5] = -min(patient.d2*P2,patient.Pmax) + patient.d1 * P1;

    end

    indexInterval = findall(x -> x>t_start && x<t_end, patient.u[:,1]);
    
    insulinTime = patient.u[indexInterval, 1];
   
    pushfirst!(insulinTime, t_start);
    push!(insulinTime, t_end);
    
    
    TS_startIndx = findlast(x -> x == t_start, timeSoln.T);
    if(isnothing(TS_startIndx))
        TS_startIndx = 1
    end

    ODEinit = [ timeSoln.GIQ[TS_startIndx, 1], timeSoln.GIQ[TS_startIndx, 2],timeSoln.GIQ[TS_startIndx, 3],
        timeSoln.P[TS_startIndx, 1], timeSoln.P[TS_startIndx, 2] ];

    tFinal = [];
    IntsFinal = [[],[],[],[],[]];
    timeSoln.T = timeSoln.T[1:TS_startIndx];
    timeSoln.GIQ = timeSoln.GIQ[1:TS_startIndx, :];
    timeSoln.P = timeSoln.P[1:TS_startIndx, :];

    for i in 1:size(insulinTime, 1)-1
        
        prob = ODEProblem(ICING_model_ODE!, ODEinit, (insulinTime[i], insulinTime[i+1]));
        num_sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8);
        ODEinit = num_sol[end];

        tFinal = cat(tFinal, num_sol.t[2:end], dims=1); #index 2:end for no repeating

        for i in 2:length(num_sol.t) # 2 for no repeating
            IntsFinal[1] = cat(IntsFinal[1], num_sol.u[i][1], dims=1);
            IntsFinal[2] = cat(IntsFinal[2], num_sol.u[i][2], dims=1);
            IntsFinal[3] = cat(IntsFinal[3], num_sol.u[i][3], dims=1);
            IntsFinal[4] = cat(IntsFinal[4], num_sol.u[i][4], dims=1);
            IntsFinal[5] = cat(IntsFinal[5], num_sol.u[i][5], dims=1);
        end
        
    end

    for i in 1:size(IntsFinal[1], 1)
        
        timeSoln.GIQ = [timeSoln.GIQ ; IntsFinal[1][i] IntsFinal[2][i] IntsFinal[3][i]];
        timeSoln.P = [timeSoln.P ; IntsFinal[4][i] IntsFinal[5][i] ];
    end
    timeSoln.T = cat(timeSoln.T, tFinal, dims = 1)

    resampleHourlyBG(patient, timeSoln, t_start);
    
end

