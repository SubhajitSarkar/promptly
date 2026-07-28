# segment: battery
# description: Shows battery level when below 30% or charging
# elements: battery
typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=30
typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND=160
typeset -g POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND=70
typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND=244
typeset -g POWERLEVEL9K_BATTERY_STAGES=('%K{232}▏  ' '%K{232}▎  ' '%K{232}▍  ' '%K{232}▌  ' '%K{232}▋  ' '%K{232}▊  ' '%K{232}▉  ' '%K{232}█  ')
typeset -g POWERLEVEL9K_BATTERY_VERBOSE=false
