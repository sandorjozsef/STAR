module Visualizer

    using Plots

    export plot_SignDiffBG_Mat2Jul
    function plot_SignDiffBG_Mat2Jul(MatlabPatient, JuliaPatient)
        display(plot(MatlabPatient.Treal, MatlabPatient.Greal - JuliaPatient.Greal, label = "MAT-JUL BG", title = MatlabPatient.Name))
    end

end