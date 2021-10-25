    include("JuliaStatistics.jl")
    using .JuliaStatistics
    
    julpath1 = "$(pwd())\\sim_results\\JuliaResults\\Simresults-2021-10-25_20_51"
    julpath2 = "$(pwd())\\sim_results\\JuliaResults\\Simresults-2021-10-24_15_18"
    
    # all 1 hour treatment by matlab
    matpath1 = "$(pwd())\\sim_results\\MatLabResults\\3hour_ode45_1e_6"
    matpath2 = "$(pwd())\\sim_results\\MatLabResults\\ode45_1e_8"
    matpath3 = "$(pwd())\\sim_results\\MatLabResults\\ode45_1e_12"

    
    dstpath1 = "$(pwd())\\sim_stats\\res1.csv"
    dstpath2 = "$(pwd())\\sim_stats\\res2.csv"

    #JuliaStatistics.calculate_signDiffBG(matpath1, julpath1)
    #JuliaStatistics.calculate_signDiffBG(julpath1, matpath1)
    #JuliaStatistics.calculate_signDiffBG(matpath2, matpath1)
    #JuliaStatistics.calculate_signDiffBG(julpath2, julpath1)

    JuliaStatistics.plot_simulation(matpath1)
    JuliaStatistics.plot_simulation(julpath1)
    
    #JuliaStatistics.createStatistics(julpath1, dstpath2)
    JuliaStatistics.createStatistics(matpath1, dstpath1)