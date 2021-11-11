using Gtk

builder = GtkBuilder(filename="src/GUI/SimulatorWindow.glade")

win = builder["SimulatorWindow"]
start_btn = builder["start_btn"]
srcDir = builder["srcDir"]
dstDir = builder["dstDir"]
mode = builder["mode"]
measurement_timing = builder["measurement_timing"]
nutrition_dosing = builder["nutrition_dosing"]

function on_button_clicked(w)
    println(  "\"", get_gtk_property(w, :label, String),"\"", " button has been clicked")
    println( get_gtk_property(srcDir, :label, String))
    println( get_gtk_property(srcDir, :title, String))
end
signal_connect(on_button_clicked, start_btn, "clicked")


showall(win)

