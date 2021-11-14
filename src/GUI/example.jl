using Gtk
using ThreadPools
include("example2.jl")

btn = GtkButton("Start")
sp = GtkSpinner()
ent = GtkEntry()

grid = GtkGrid()
grid[1,1] = btn
grid[2,1] = sp
grid[1:2,2] = ent

function foo(asd)
    println(asd)
end



function working()
    run("hi")
    sleep(4)
    println("done")
end

signal_connect(btn, "clicked") do widget
    spawnbg(working)
end

win = GtkWindow(grid, "Progress Bar", 200, 200)
showall(win)