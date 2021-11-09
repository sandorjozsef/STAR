include("JuliaStatistics.jl")
using .JuliaStatistics
    
if ispath("$(pwd())\\sim_stats") == false
    mkdir("$(pwd())\\sim_stats")
end

if ispath("$(pwd())\\graphs") == false
    mkdir("$(pwd())\\graphs")
end

julpath1 = "$(pwd())\\patients_data\\simulated\\julia_results\\all_STAR_3hour_Tsit_8"
julpath2 = "$(pwd())\\patients_data\\simulated\\julia_results\\all_STAR_3hour_DP5_8"
julpath3 = "$(pwd())\\patients_data\\simulated\\julia_results\\all_STAR_1hour_Tsit_8"

matpath1 = "$(pwd())\\patients_data\\simulated\\matlab_results\\3hour_ode45_1e_6"
# all 1 hour treatment by matlab
matpath2 = "$(pwd())\\patients_data\\simulated\\matlab_results\\1hour_ode45_1e_8"
matpath3 = "$(pwd())\\patients_data\\simulated\\matlab_results\\1hour_ode45_1e_12"

matpath4 = "$(pwd())\\patients_data\\original\\Interesting_Patients_mat"

javapath1 = "$(pwd())\\patients_data\\original\\Interesting_Patients_java"

dstpath1 = "$(pwd())\\sim_stats\\res1.csv"
dstpath2 = "$(pwd())\\sim_stats\\res2.csv"
dstpath3 = "$(pwd())\\sim_stats\\res3.csv"


#JuliaStatistics.calculate_treatments_signDiffBG(julpath1, julpath2)
#JuliaStatistics.calculate_treatments_signDiffBG(julpath3, matpath2)
#JuliaStatistics.calculate_treatments_signDiffBG(matpath2, matpath1)
#JuliaStatistics.calculate_treatments_signDiffBG(julpath2, julpath1) 
#JuliaStatistics.calculate_treatments_signDiffBG(javapath1, julpath1)

#JuliaStatistics.plot_simulation(julpath1)
#JuliaStatistics.plot_simulation(javapath1)
#JuliaStatistics.plot_simulation(matpath4)

#JuliaStatistics.create_statistics(matpath4, dstpath1)
#JuliaStatistics.create_statistics(julpath1, dstpath2)
#JuliaStatistics.create_statistics(javapath1, dstpath3)

#JuliaStatistics.compare_treatments(julpath1, julpath2)
JuliaStatistics.compare_treatments(julpath3, matpath2)
#JuliaStatistics.compare_treatments(javapath1, julpath1)

#JuliaStatistics.plot_cohort_CDF(julpath1)
