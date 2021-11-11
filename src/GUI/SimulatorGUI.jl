using Gtk

builder = GtkBuilder(filename="src/GUI/SimulatorWindow.glade")

win = builder["SimulatorWindow"]
start_btn = builder["start_btn"]
srcDir = builder["srcDir"]
srcDir_btn = builder["srcDir_btn"]
dstDir = builder["dstDir"]
dstDir_btn = builder["dstDir_btn"]
mode = builder["mode"]
measurement_timing = builder["measurement_timing"]
nutrition_dosing = builder["nutrition_dosing"]
output_text = builder["output_text"]

function on_start_simulation_click(w)
    
    println(  "\"", get_gtk_property(w, :label, String),"\"", " button has been clicked")
    println( "src: ", get_gtk_property(srcDir, :text, String))
    println( "dst: ", get_gtk_property(dstDir, :text, String))
    set_gtk_property!(output_text, :text, "AAA")

end
signal_connect(on_start_simulation_click, start_btn, "clicked")



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


showall(win)

