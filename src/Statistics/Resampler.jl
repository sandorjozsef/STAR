module Resampler

# resampling hourly BG from TimeSoln
function resampleHourlyBG(timeSolnT::Vector{Float64}, timeSolnGIQ::Matrix{Float64})
    hourlyBG = [timeSolnGIQ[1,1]]
    hours = 1
    for i in 2:length(timeSolnT)
        if timeSolnT[i] >= hours * 60
            push!(hourlyBG, timeSolnGIQ[i,1])
            hours = hours + 1
        end
    end
    return hourlyBG
end

# create rare GIQ from timesolnGIQ at measuring time
function createGIQ(Treal::Vector{Float64},  dense_T::Vector{Float64}, dense_GIQ::Matrix{Float64})
    j = 1
    rare_GIQ = Matrix{Float64}(undef, length(Treal), 3)
    for i in 1:length(dense_T)
        if Treal[j] == dense_T[i]
            rare_GIQ[j,1] = dense_GIQ[i,1]
            rare_GIQ[j,2] = dense_GIQ[i,2]
            rare_GIQ[j,3] = dense_GIQ[i,3]
            j = j+1
        end
        
    end
    
    return rare_GIQ
end

# hourly resample for  P, PN, u
function resample_hourly(mtx::Matrix{Float64}, func)
    
    mtx_hourly = [ func( mtx[1,2]) ]
    cnt = 0.0
    for i in 2:length(mtx[:,1])
        if (mtx[i,1] - mtx[i-1,1] + cnt) < 60
            mtx_hourly[end] = mtx_hourly[end] + func( mtx[i,2] )
            cnt = cnt + (mtx[i,1] - mtx[i-1,1])
        end
        if (mtx[i,1] -mtx[i-1,1] + cnt ) >= 60 && (mtx[i,1] - mtx[i-1,1] + cnt) < 120
            push!(mtx_hourly, func( mtx[i,2] ) ) 
            cnt = cnt - 60 + (mtx[i,1] - mtx[i-1,1])
        end
        if (mtx[i,1] - mtx[i-1,1] + cnt) >= 120 && (mtx[i,1] - mtx[i-1,1] + cnt) < 180
            push!(mtx_hourly, func( mtx[i,2] ) ) 
            push!(mtx_hourly, func( mtx[i,2] ) ) 
            cnt = cnt - 120 + (mtx[i,1] - mtx[i-1,1])
        end
        if (mtx[i,1] - mtx[i-1,1] + cnt) >= 180 
            push!(mtx_hourly, func( mtx[i,2] ) ) 
            push!(mtx_hourly, func( mtx[i,2] ) ) 
            push!(mtx_hourly, func( mtx[i,2] ) ) 
            cnt = cnt - 180 + (mtx[i,1] - mtx[i-1,1])
        end
    end

    return mtx_hourly
end

# create step function for better view at plotting
function convert_to_stepfunction(f::Matrix{Float64})
    s = [f[1,1] f[1,2]]
    s = [s; f[1,1]+1 f[1,2]]
    for i in 2:length(f[:,1])
        s = [s; f[i,1] f[i,2]]
        s = [s; f[i,1]+1 f[i,2]]
    end
    return s
end

end