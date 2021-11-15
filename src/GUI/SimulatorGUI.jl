module SimulatorGUI

    include("$(pwd())\\src\\Simulator\\runSimulationOnPatients.jl")
    include("$(pwd())\\src\\Simulator\\Simulation_Structs.jl")
    using ThreadPools
    using .Simulation_Structs
    using Gtk

    builder = GtkBuilder(filename="src/GUI/SimulatorWindow.glade")

    GTKwin = builder["SimulatorWindow"]
    GTKstart_btn = builder["start_btn"]
    GTKsrcDir = builder["srcDir"]
    GTKsrcDir_btn = builder["srcDir_btn"]
    GTKdstDir = builder["dstDir"]
    GTKdstDir_btn = builder["dstDir_btn"]
    GTKmode = builder["mode"]
    GTKlongest_allowed = builder["longest_allowed"]
    GTKprotocol_timing = builder["protocol_timing"]
    GTKnutrition_dosing = builder["nutrition_dosing"]
    GTKtext_buffer = builder["text_buffer"]


    function initialize()
        set_gtk_property!(GTKsrcDir, :text, pwd() * "/patients_data/original/interesting_patients_mat")
        set_gtk_property!(GTKdstDir, :text, pwd() * "/patients_data/simulated/julia_results")
    end

    function runSimulations()

        srcDir = get_gtk_property(GTKsrcDir, :text, String)
        dstDir = get_gtk_property(GTKdstDir, :text, String)
        if ispath(dstDir) == false 
            mkdir(dstDir)
        end

        simulation = Simulation_Structs.Simulation()
        simulation.mode = get_gtk_property(GTKmode, :active, Int) + 1
        simulation.longest_allowed = get_gtk_property(GTKlongest_allowed, :active, Int) + 1
        simulation.protocol_timing = get_gtk_property(GTKprotocol_timing, :active, Int) + 1
        simulation.nutrition_dosing = get_gtk_property(GTKnutrition_dosing, :active, Int) + 1
        runSimulationOnPatients(srcDir, dstDir, simulation)

    end

    signal_connect(GTKstart_btn, "clicked") do widget
        println(  "\"", get_gtk_property(widget, :label, String),"\"", " button has been clicked")

        #spawnbg(runSimulations)
        runSimulations()
        
        log = open("$(pwd())\\src\\Simulator\\simulator_log.txt") do myFile
            read(myFile, String)
        end
        set_gtk_property!(GTKtext_buffer, :text, log)

    end

    function on_src_select_click(w)
        dir = open_dialog("Select Dataset Folder", action=GtkFileChooserAction.SELECT_FOLDER)
        if isdir(dir)
            set_gtk_property!(GTKsrcDir, :text, dir)
        end
    end
    signal_connect(on_src_select_click, GTKsrcDir_btn, "clicked")

    function on_dst_select_click(w)
        dir = open_dialog("Select Dataset Folder", action=GtkFileChooserAction.SELECT_FOLDER)
        if isdir(dir)
            set_gtk_property!(GTKdstDir, :text, dir)
        end
    end
    signal_connect(on_dst_select_click, GTKdstDir_btn, "clicked")

    initialize()
    showall(GTKwin)


end
