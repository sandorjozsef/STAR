module VisualiserExporter

    using Plots

    export saveSVG_plot
    function saveSVG_plot(p, filename, path)
        savefig(p, path * "\\$filename.svg")
    end

    export savePNG_plot
    function savePNG_plot(p, filename, path)
        savefig(p, path * "\\$filename.png")
    end

end