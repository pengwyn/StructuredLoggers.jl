module StructuredLoggers

using Logging, Dates, Match
import Crayons

export StructuredLogger,
    global_logger

struct StructuredLogger <: AbstractLogger
    app_name::String
    io::IO
    coloured::Bool
    StructuredLogger(app_name="", io=stderr, coloured=(io isa Base.TTY)) = new(app_name, io, coloured)
end

function Logging.handle_message(logger::StructuredLogger, level, message, _module, group, id, file, line; kwds...)
    # Dodgy hack for colours
    C(name) = logger.coloured ? getproperty(Crayons.Box, name) : identity
    
    # Note: because of the colors, rpad gets confused. So need to pad before the colour is applied.
    level_len = 7
    level_str = @match level begin
        Logging.Info => C(:GREEN_FG)(rpad("info", level_len))
        Logging.Debug => C(:GREEN_FG)(rpad("debug", level_len))
        Logging.Warn => C(:LIGHT_YELLOW_FG)(rpad("warning", level_len))
        Logging.Error => C(:LIGHT_RED_FG)(rpad("error", level_len))
        _ => C(:WHITE_FG)(rpad(string(level), level_len))
    end

    if logger.app_name != ""
        message = string(C(:LIGHT_GRAY_FG)("$(logger.app_name): ")) * message
    end
    println(logger.io, join([C(:LIGHT_GRAY_FG)(Dates.format(now(), "yyyy-mm-ddTHH:MM:SS:sss")),
                             "[$level_str]",
                             rpad(message, 30),
                             (map(collect(kwds)) do (key,val)
                              string(C(:LIGHT_CYAN_FG)(string(key))) * "=" * string(C(:MAGENTA_FG)(string(val)))
                              end)...], " "))
    flush(logger.io)
    nothing
end

Logging.shouldlog(::StructuredLogger, level, _module, group, id) = true
Logging.min_enabled_level(::StructuredLogger) = Logging.Info

end
