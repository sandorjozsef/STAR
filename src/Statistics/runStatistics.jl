include("JuliaStatistics.jl")
using .JuliaStatistics
    
julpath1 = "$(pwd())\\sim_results\\JuliaResults\\Simresults-2021-10-26_13_29"
julpath2 = "$(pwd())\\sim_results\\JuliaResults\\Simresults-2021-10-26_14_11"
    
# all 1 hour treatment by matlab
matpath1 = "$(pwd())\\sim_results\\MatLabResults\\3hour_ode45_1e_6"
matpath2 = "$(pwd())\\sim_results\\MatLabResults\\ode45_1e_8"
matpath3 = "$(pwd())\\sim_results\\MatLabResults\\ode45_1e_12"


javapath1 = "$(pwd())\\input\\Interesting_Patients_java"
matpath4 = "$(pwd())\\input\\Interesting_Patients_mat"

    
dstpath1 = "$(pwd())\\sim_stats\\res1.csv"
dstpath2 = "$(pwd())\\sim_stats\\res2.csv"

#JuliaStatistics.calculate_signDiffBG(julpath1, julpath2)
#JuliaStatistics.calculate_signDiffBG(julpath1, matpath1)
#JuliaStatistics.calculate_signDiffBG(matpath2, matpath1)
#JuliaStatistics.calculate_signDiffBG(julpath2, julpath1)

#JuliaStatistics.plot_simulation(julpath2)
#JuliaStatistics.plot_simulation(julpath2)
    
#JuliaStatistics.createStatistics(julpath1, dstpath2)
#JuliaStatistics.createStatistics(matpath4, dstpath1)

#JuliaStatistics.plot_simulation(matpath4)
#JuliaStatistics.plot_simulation(javapath1)