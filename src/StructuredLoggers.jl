module StructuredLoggers

using Logging, Dates, Match
using Crayons.Box

export StructuredLogger,
    global_logger

struct StructuredLogger <: AbstractLogger end

function Logging.handle_message(::StructuredLogger, level, message, _module, group, id, file, line; kwds...)
    # Note: because of the colors, rpad gets confused. So need to pad before the colour is applied.
    level_len = 7
    level_str = @match level begin
        Logging.Info => GREEN_FG(rpad("info", level_len))
        Logging.Debug => GREEN_FG(rpad("debug", level_len))
        Logging.Warn => LIGHT_YELLOW_FG(rpad("warning", level_len))
        Logging.Error => LIGHT_RED_FG(rpad("error", level_len))
        _ => WHITE_FG(rpad(string(level), level_len))
    end
    println(stderr, join([LIGHT_GRAY_FG(Dates.format(now(), "yyyy-mm-ddTHH:MM:SS:sss")),
                        "[$level_str]",
                        rpad(message, 30),
                        (map(collect(kwds)) do (key,val)
                         string(LIGHT_CYAN_FG(string(key))) * "=" * string(MAGENTA_FG(string(val)))
                         end)...], " "))
    nothing
end

Logging.shouldlog(::StructuredLogger, level, _module, group, id) = true
Logging.min_enabled_level(::StructuredLogger) = Logging.Info

end
