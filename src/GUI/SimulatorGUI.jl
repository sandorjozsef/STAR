module SimulatorGUI

using Gtk
include("SimulatorGUIInfo.jl")
include("$(pwd())\\src\\Simulator\\runSimulations.jl")


builder = GtkBuilder(filename="src/GUI/SimulatorWindow.glade")

win = builder["SimulatorWindow"]
start_btn = builder["start_btn"]
srcDir = builder["srcDir"]
srcDir_btn = builder["srcDir_btn"]
dstDir = builder["dstDir"]
dstDir_btn = builder["dstDir_btn"]
mode = builder["mode"]
longest_allowed = builder["longest_allowed"]
protocol_timing = builder["protocol_timing"]
nutrition_dosing = builder["nutrition_dosing"]
text_buffer = builder["text_buffer"]


function initialize()
    set_gtk_property!(srcDir, :text, pwd() * "/patients_data/original/interesting_patients_mat")
    set_gtk_property!(dstDir, :text, pwd() * "/patients_data/simulated/julia_results")
end

signal_connect(start_btn, "clicked") do widget
    println(  "\"", get_gtk_property(widget, :label, String),"\"", " button has been clicked")

    simInfo = SimulatorGUIInfo()
    simInfo.srcDir = get_gtk_property(srcDir, :text, String)
    simInfo.dstDir = get_gtk_property(dstDir, :text, String)
    simInfo.mode = get_gtk_property(mode, :active, Int) + 1
    simInfo.longest_allowed = get_gtk_property(longest_allowed, :active, Int) + 1
    simInfo.protocol_timing = get_gtk_property(protocol_timing, :active, Int) + 1
    simInfo.nutrition_dosing = get_gtk_property(nutrition_dosing, :active, Int) + 1

    runSimulationsGUI(simInfo)

    myText = open("$(pwd())\\src\\Simulator\\simulator_log.txt") do myFile
        read(myFile, String)
    end
    
    set_gtk_property!(text_buffer, :text, myText)

end

function on_src_select_click(w)
    dir = open_dialog("Select Dataset Folder", action=GtkFileChooserAction.SELECT_FOLDER)
    if isdir(dir)
        set_gtk_property!(srcDir, :text, dir)
    end
end
signal_connect(on_src_select_click, srcDir_btn, "clicked")

function on_dst_select_click(w)
    dir = open_dialog("Select Dataset Folder", action=GtkFileChooserAction.SELECT_FOLDER)
    if isdir(dir)
        set_gtk_property!(dstDir, :text, dir)
    end
end
signal_connect(on_dst_select_click, dstDir_btn, "clicked")

initialize()
showall(win)


end
