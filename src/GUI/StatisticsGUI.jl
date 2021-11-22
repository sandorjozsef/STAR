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
    using ImageView
    using Images
    using Dates
    using TestImages

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
    btn_input1 = builder["btn_input1"]
    input2 = builder["input2"]
    btn_input2 = builder["btn_input2"]
    output = builder["output"]
    btn_output = builder["btn_output"]
    mainbox = builder["mainbox"]
    help = builder["help"]
    error = builder["error"]
    activeBtn = Vector{GtkRadioButton}(undef,1)
    tmp = "$(pwd())\\src\\GUI\\tmp"
    dirs = ["", "", ""]
    frame, c = ImageView.frame_canvas(:auto)
    push!(mainbox, frame)

    

    function  plot_patient_metabolics_GUI()
        patientName1 = splitext(readdir(dirs[1])[1])[1]
        Patient1 = Serializer.deserialize(dirs[1], patientName1)
        p = Visualizer.plot_patient_metabolics(Patient1)
        VisualiserExporter.savePNG_plot(p, "graph", tmp)
        img = load("$tmp\\graph.png")
        imshow(c, img)
    end

    function plot_patient_BG_GUI()
        patientName1 = splitext(readdir(dirs[1])[1])[1]
        Patient1 = Serializer.deserialize(dirs[1], patientName1)
        p = Visualizer.plot_patient_BG(Patient1)
        VisualiserExporter.savePNG_plot(p, "graph", tmp)
        img = load("$tmp\\graph.png")
        imshow(c, img)
    end

    function plot_CDF_GUI()
        patientName1 = splitext(readdir(dirs[1])[1])[1]
        Patient1 = Serializer.deserialize(dirs[1], patientName1)
        p = Visualizer.plot_CDF(Patient1.hourlyBG)
        VisualiserExporter.savePNG_plot(p, "graph", tmp)
        img = load("$tmp\\graph.png")
        imshow(c, img)
    end

    function plot_cohort_CDF_GUI()
        p = JuliaStatistics.cohort_CDF(dirs[1])
        VisualiserExporter.savePNG_plot(p, "graph", tmp)
        img = load("$tmp\\graph.png")
        imshow(c, img)
    end

    function plot_compare_patient_BG_GUI()
        patientName1 = splitext(readdir(dirs[1])[1])[1]
        Patient1 = Serializer.deserialize(dirs[1], patientName1)
        patientName2 = splitext(readdir(dirs[2])[1])[1]
        Patient2 = Serializer.deserialize(dirs[2], patientName2)
        p = Visualizer.plot_compare_patient_BG(Patient1, Patient2)
        VisualiserExporter.savePNG_plot(p, "graph", tmp)
        img = load("$tmp\\graph.png")
        imshow(c, img)
    end

    function plot_compare_patient_treatment_GUI()
        patientName1 = splitext(readdir(dirs[1])[1])[1]
        Patient1 = Serializer.deserialize(dirs[1], patientName1)
        patientName2 = splitext(readdir(dirs[2])[1])[1]
        Patient2 = Serializer.deserialize(dirs[2], patientName2)
        p = Visualizer.plot_compare_patient_treatment(Patient1, Patient2)
        VisualiserExporter.savePNG_plot(p, "graph", tmp)
        img = load("$tmp\\graph.png")
        imshow(c, img)
    end

    function create_statistics_GUI()
        img = testimage("lena_color")
        imshow(c, img)
        filename = "Stats-" * string(today()) *"_"* string(hour(now())) *"_"* string(minute(now()))
        dstpath =  "$(dirs[3])/$filename.csv"
        JuliaStatistics.create_statistics(dirs[1], dstpath)
        set_gtk_property!(help, :label, "Created statistics in: $dstpath")
    end

    btn_func_dict = Dict(
        radbtn1 => plot_patient_metabolics_GUI,
        radbtn2 => plot_patient_BG_GUI,
        radbtn3 => plot_CDF_GUI,
        radbtn4 => plot_cohort_CDF_GUI,
        radbtn5 => plot_compare_patient_BG_GUI,
        radbtn6 => plot_compare_patient_treatment_GUI,
        radbtn7 => create_statistics_GUI
    )

    function initialize()
        if isdir(tmp)
            rm(tmp, recursive = true)
        end
        mkdir(tmp)

        activeBtn[1] = radbtn1

        for r in keys(btn_func_dict)
            signal_connect(r, "toggled") do _
                println("Changed to: ", get_gtk_property(r, :label, String))
                activeBtn[1] = r
            end
        end

        set_gtk_property!(input1, :text, pwd() * "\\patients_data\\simulated\\julia_results\\intr_STAR_3hour_Tsit_8\\bb8daa4e-6e40-4c05-827f-fc213c8b696b.jld2")
        set_gtk_property!(input2, :text, pwd() * "\\patients_data\\simulated\\julia_results\\intr_STAR_historic_Tsit_8\\bb8daa4e-6e40-4c05-827f-fc213c8b696b.jld2")
        set_gtk_property!(output, :text, pwd() * "\\sim_stats\\")

    end

    function run_active_function()

        inputtext1 = get_gtk_property(input1, :text, String)
        dirs[1] = dirname(inputtext1)

        inputtext2 = get_gtk_property(input2, :text, String)
        dirs[2] = dirname(inputtext2)

        outputtext = get_gtk_property(output, :text, String)
        dirs[3] = dirname(outputtext)

        btn_func_dict[activeBtn[1]]()
        
    end
    
   

    signal_connect(process_btn, "clicked") do _
        println("Processing ...")

        if isdir(tmp)
            rm(tmp, recursive = true)
        end
        mkdir(tmp)

        run_active_function()

    end

    function on_input1_select_click(w)
        println("Clicked on opening file button")
        dir = open_dialog("Select Patient Dataset", action=GtkFileChooserAction.OPEN)
        set_gtk_property!(input1, :text, dir)
    end
    signal_connect(on_input1_select_click, btn_input1, "clicked")

    function on_input2_select_click(w)
        dir = open_dialog("Select Patient Dataset", action=GtkFileChooserAction.OPEN)
        set_gtk_property!(input2, :text, dir)
    end
    signal_connect(on_input2_select_click, btn_input2, "clicked")

    function on_output_select_click(w)
        dir = open_dialog("Select Destination Folder", action=GtkFileChooserAction.OPEN)
        set_gtk_property!(output, :text, dir)
    end
    signal_connect(on_output_select_click, btn_output, "clicked")

    initialize()
    maximize(win)
    showall(win)
    
end