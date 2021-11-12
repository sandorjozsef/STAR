using Gtk
using Distributed

btn = GtkButton("Start")
sp = GtkSpinner()
ent = GtkEntry()

grid = GtkGrid()
grid[1,1] = btn
grid[2,1] = sp
grid[1:2,2] = ent

id = addprocs(1)[1]

@everywhere function working()
    println("working")
end

signal_connect(btn, "clicked") do widget
    start(sp)
    
        @async begin
            s = @fetchfrom id begin
                working()
                sleep(4)
                return "I am back"
            end
            @Gtk.sigatom begin
                stop(sp)
                set_gtk_property!(ent,:text,s)
            end
        end
    
end

win = GtkWindow(grid, "Progress Bar", 200, 200)
showall(win)