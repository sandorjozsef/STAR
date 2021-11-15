module StatisticsGUI

    include("$(pwd())\\src\\Statistics\\Visualizer.jl")
    include("$(pwd())\\src\\Statistics\\VisualizerExporter.jl")
    include("$(pwd())\\src\\Statistics\\Serializer.jl")
    include("$(pwd())\\src\\Statistics\\JuliaStatistics.jl")
    using .Serializer
    using .Visualizer
    using .VisualiserExporter
    using .JuliaStatistics
    using Gtk

    builder = GtkBuilder(filename="src/GUI/StatisticsWindow.glade")
    win = builder["StatisticsWindow"]

    radbtn1 = builder["radiobutton1"]
    radbtn2 = builder["radiobutton2"]
    radbtn3 = builder["radiobutton3"]
    radbtn4 = builder["radiobutton4"]
    radbtn5 = builder["radiobutton5"]
    radbtn6 = builder["radiobutton6"]
    radbtn7 = builder["radiobutton7"]
    process_btn = builder["process_btn"]
    input1 = builder["input1"]
    input2 = builder["input2"]
    image = builder["image"]


    radios = [radbtn1, radbtn2, radbtn3, radbtn4, radbtn5, radbtn6, radbtn7]
    activeFunction = Vector{Int}(undef,1)
    tmp = "$(pwd())\\src\\GUI\\tmp"

    function initialize()
        if isdir(tmp)
            rm(tmp, recursive = true)
        end
        mkdir(tmp)

        activeFunction[1] = 1
        for r in radios
            signal_connect(r, "pressed") do _
                println("Changed to: $(get_gtk_property(r, :label, String))")
                activeFunction[1] = findfirst(x -> x == r, radios)
                println(activeFunction[1])
            end
        end
        set_gtk_property!(input1, :text, pwd() * "\\patients_data\\simulated\\julia_results\\intr_STAR_3hour_Tsit_8\\bb8daa4e-6e40-4c05-827f-fc213c8b696b.jld2")
        set_gtk_property!(input2, :text, pwd() * "\\patients_data\\simulated\\julia_results\\intr_STAR_historic_Tsit_8\\bb8daa4e-6e40-4c05-827f-fc213c8b696b.jld2")
        
    end
    initialize()

    signal_connect(process_btn, "clicked") do _
        println("Processing ...")

        inputtext1 = get_gtk_property(input1, :text, String)
        dir1 = dirname(inputtext1)
        

        if activeFunction[1] == 1
            patientName1 = splitext(readdir(dir1)[1])[1]
            Patient1 = Serializer.deserialize(dir1, patientName1)
            p = Visualizer.plot_patient_metabolics(Patient1)
            VisualiserExporter.savePNG_plot(p, "graph", tmp)
            set_gtk_property!(image, :file, "$tmp\\graph.png")
        end

        if activeFunction[1] == 2
            patientName1 = splitext(readdir(dir1)[1])[1]
            Patient1 = Serializer.deserialize(dir1, patientName1)
            p = Visualizer.plot_patient_BG(Patient1)
            VisualiserExporter.savePNG_plot(p, "graph", tmp)
            set_gtk_property!(image, :file, "$tmp\\graph.png")
        end

        if activeFunction[1] == 3
            patientName1 = splitext(readdir(dir1)[1])[1]
            Patient1 = Serializer.deserialize(dir1, patientName1)
            p = Visualizer.plot_CDF(Patient1.hourlyBG)
            VisualiserExporter.savePNG_plot(p, "graph", tmp)
            set_gtk_property!(image, :file, "$tmp\\graph.png")
        end

        if activeFunction[1] == 4
            p = JuliaStatistics.cohort_CDF(dir1)
            VisualiserExporter.savePNG_plot(p, "graph", tmp)
            set_gtk_property!(image, :file, "$tmp\\graph.png")
        end

        rm(tmp)
    end

   

    
    showall(win)
    
end