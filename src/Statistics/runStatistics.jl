    include("JuliaStatistics.jl")
    using .JuliaStatistics
    
    julpath1 = "$(pwd())\\src\\Statistics\\JuliaResults\\Simresults-2021-10-24_15_25"
    julpath2 = "$(pwd())\\src\\Statistics\\JuliaResults\\Simresults-2021-10-24_15_18"
    
    # all 1 hour treatment by matlab
    matpath1 = "$(pwd())\\src\\Statistics\\MatLabResults\\3hour_ode45_1e_6"
    matpath2 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_8"
    matpath3 = "$(pwd())\\src\\Statistics\\MatLabResults\\ode45_1e_12"

    
    dstpath1 = "$(pwd())\\stats\\res1.csv"
    dstpath2 = "$(pwd())\\stats\\res2.csv"

    #calculate_signDiffBG(matpath1, julpath1)
    #calculate_signDiffBG(julpath1, matpath1)
    #calculate_signDiffBG(matpath2, matpath1)
    #calculate_signDiffBG(julpath2, julpath1)

    #plot_simulation(matpath1)
    #plot_simulation(julpath1)
    
    #JuliaStatistics.createStatistics(julpath1, dstpath2)
    JuliaStatistics.createStatistics(matpath1, dstpath1)