using Gtk

builder = GtkBuilder(filename="src/GUI/example.glade")

win = builder["window1"]
b = builder["button1"]

function on_button_clicked(w)
    println(  "\"", get_gtk_property(w, :label, String),"\"", " button has been clicked")
end
signal_connect(on_button_clicked, b, "clicked")


showall(win)

