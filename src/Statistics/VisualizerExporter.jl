module VisualiserExporter

    using Plots

    function savePNG_plot(p, fullpath)
        png(p, fullpath)
    end

end