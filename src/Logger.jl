module Logger

    src = "$(pwd())\\src\\Simulator\\simulator_log.txt"

    function clear_log()
        if ispath(src)
            rm(src)
        end
    end

    function log(log)
        open(src, "a") do f
            write(f, "$log\n")
        end
    end

end