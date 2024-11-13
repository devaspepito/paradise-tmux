#!/usr/bin/env bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# title: paradise                                                      +
# version: 1.0.0                                                       +
# repository: https://github.com/devaspepito/paradise-tmux             +
# author: Brayan Ocampo                                                +
# email: contact.ocampo.info@gmail.com                                 +
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

# Most of the variables are prefixed with `@paradise-tmux-` so that tmux has a unique namespace
#
# The variables are:
# - @paradise-tmux-bg: background color of the status line
# - @paradise-tmux-fg: foreground color of the status line
# - @paradise-tmux-status: position of the status line (top or bottom)
# - @paradise-tmux-justify: justification of the status line (left, centre or right)
# - @paradise-tmux-indicator: whether to show the indicator of the prefix
# - @paradise-tmux-indicator-str: string of the indicator
# - @paradise-tmux-right: whether to show the right side of the status line
# - @paradise-tmux-left: whether to show the left side of the status line
# - @paradise-tmux-status-right: content of the right side of the status line
# - @paradise-tmux-status-left: content of the left side of the status line
# - @paradise-tmux-status-right-extra: extra content of the right side of the status line
# - @paradise-tmux-status-left-extra: extra content of the left side of the status line
# - @paradise-tmux-window-status-format: format of the window status
# - @paradise-tmux-expanded-icon: icon for expanded windows
# - @paradise-tmux-show-expanded-icon-for-all-tabs: whether to show the expanded icon for all tabs
# - @paradise-tmux-use-arrow: whether to use arrows in the status line
# - @paradise-tmux-right-arrow: right arrow symbol
# - @paradise-tmux-left-arrow: right left symbol

default_color="#[bg=default,fg=default,bold]"

# variables
bg=$(get_tmux_option "@paradise-tmux-bg" '#698DDA')
fg=$(get_tmux_option "@paradise-tmux-fg" '#000000')

use_arrow=$(get_tmux_option "@paradise-tmux-use-arrow" false)
larrow="$("$use_arrow" && get_tmux_option "@paradise-tmux-left-arrow" "")"
rarrow="$("$use_arrow" && get_tmux_option "@paradise-tmux-right-arrow" "")"

status=$(get_tmux_option "@paradise-tmux-status" "bottom")
justify=$(get_tmux_option "@paradise-tmux-justify" "centre")

indicator_state=$(get_tmux_option "@paradise-tmux-indicator" true)
indicator_str=$(get_tmux_option "@paradise-tmux-indicator-str" " tmux ")
indicator=$("$indicator_state" && echo " $indicator_str ")

right_state=$(get_tmux_option "@paradise-tmux-right" true)
left_state=$(get_tmux_option "@paradise-tmux-left" true)

status_right=$("$right_state" && get_tmux_option "@paradise-tmux-status-right" "#S")
status_left=$("$left_state" && get_tmux_option "@paradise-tmux-status-left" "${default_color}#{?client_prefix,,${indicator}}#[bg=${bg},fg=${fg},bold]#{?client_prefix,${indicator},}${default_color}")
status_right_extra="$status_right$(get_tmux_option "@paradise-tmux-status-right-extra" "")"
status_left_extra="$status_left$(get_tmux_option "@paradise-tmux-status-left-extra" "")"

window_status_format=$(get_tmux_option "@paradise-tmux-window-status-format" ' #I:#W ')

expanded_icon=$(get_tmux_option "@paradise-tmux-expanded-icon" '󰊓 ')
show_expanded_icon_for_all_tabs=$(get_tmux_option "@paradise-tmux-show-expanded-icon-for-all-tabs" false)

# Setting the options in tmux
tmux set-option -g status-position "$status"
tmux set-option -g status-style bg=default,fg=default
tmux set-option -g status-justify "$justify"

tmux set-option -g status-left "$status_left_extra"
tmux set-option -g status-right "$status_right_extra"

tmux set-option -g window-status-format "$window_status_format"
"$show_expanded_icon_for_all_tabs" && tmux set-option -g window-status-format " ${window_status_format}#{?window_zoomed_flag,${expanded_icon},}"

tmux set-option -g window-status-current-format "#[fg=${bg}]$larrow#[bg=${bg},fg=${fg}]${window_status_format}#{?window_zoomed_flag,${expanded_icon},}#[fg=${bg},bg=default]$rarrow"
