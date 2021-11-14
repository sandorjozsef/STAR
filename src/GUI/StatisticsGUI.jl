module StatisticsGUI
    using Gtk

    builder = GtkBuilder(filename="src/GUI/StatisticsWindow.glade")

    win = builder["StatisticsWindow"]

    showall(win)
    
end