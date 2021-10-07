function BG_sensor(patient, timeSoln)
   
    push!(patient.Treal, timeSoln.T[end]);
    push!(patient.Greal, timeSoln.GIQ[end,1]);
    
    push!(patient.Ireal, timeSoln.GIQ[end,2]); # this can not be done in reality, it is now for statistics
    push!(patient.Qreal, timeSoln.GIQ[end,3]); # this can not be done in reality, it is now for statistics
end