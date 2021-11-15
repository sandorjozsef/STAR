module StatisticsGUI

    include("$(pwd())\\src\\Statistics\\Visualizer.jl")
    include("$(pwd())\\src\\Statistics\\VisualizerExporter.jl")
    include("$(pwd())\\src\\Statistics\\Serializer.jl")
    using .Serializer
    using .Visualizer
    using .VisualiserExporter
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
    mainbox = builder["mainbox"]

    image = GtkImage("")
    push!(mainbox, image)

    radios = [radbtn1, radbtn2, radbtn3, radbtn4, radbtn5, radbtn6, radbtn7]
    activeFunction = 1

    

    signal_connect(process_btn, "clicked") do _
        println("Processing ...")

        inputtext1 = get_gtk_property(input1, :text, String)
        dir = dirname(inputtext1)

        if activeFunction == 1
            patientName = splitext(readdir(dir)[1])[1]
            println(patientName)
            Patient = Serializer.deserialize(dir, patientName)
            p1 = Visualizer.plot_patient_metabolics(Patient)
            VisualiserExporter.savePNG_plot(p1, patientName, "$(pwd())\\src\\GUI\\tmp")
           
            set_gtk_property!(image, :file, "$(pwd())\\src\\GUI\\tmp\\bb8daa4e-6e40-4c05-827f-fc213c8b696b.png")
        end

    end

    function initialize()
        for r in radios
            signal_connect(r, "pressed") do _
                println("Changed to: $(get_gtk_property(r, :label, String))")
                activeFunction = findfirst(x -> x == r, radios)
                println(activeFunction)
            end
        end
        set_gtk_property!(input1, :text, pwd() * "\\patients_data\\simulated\\julia_results\\intr_STAR_3hour_Tsit_8\\bb8daa4e-6e40-4c05-827f-fc213c8b696b.jld2")
        set_gtk_property!(input2, :text, pwd() * "\\patients_data\\simulated\\julia_results\\intr_STAR_historic_Tsit_8\\bb8daa4e-6e40-4c05-827f-fc213c8b696b.jld2")
        
    end

    initialize()
    showall(win)
    
end