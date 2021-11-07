module VisualiserExporter

    using Plots

    export saveSVG_plot
    function saveSVG_plot(p, filename)
        savefig(p, pwd() * "\\graphs\\$filename.svg")
    end

    export savePNG_plot
    function savePNG_plot(p, filename)
        savefig(p, pwd() * "\\graphs\\$filename.png")
    end

end