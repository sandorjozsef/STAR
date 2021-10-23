function BG_sensor(patient, timeSoln)
   
    push!(patient.Treal, timeSoln.T[end]);
    push!(patient.Greal, timeSoln.GIQ[end,1]);
    
end