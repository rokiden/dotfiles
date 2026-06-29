return {
    terminal = "alacritty",
    file_manager = "nautilus",
    runmenu = "rofi -show combi",
    calculator = "alacritty -e bash --login -c ipython",
    clipboard = "cliphist list| rofi -dmenu| cliphist decode| wl-copy",
    config_edit = "alacritty -e bash -c \"find dotfiles -type f ! -path '*/venv/*' ! -path '*/.git/*' ! -name '*.swp' | cut -d '/' -f2- | rofi -dmenu | xargs -ori vim dotfiles/{}\"",
    lock = "loginctl lock-session",
    colorpicker = "hyprpicker| wl-copy",
    notifications = "swaync-client -t -sw",
    screenshot_monitor = "hyprshot -m output",
    screenshot_window  = "hyprshot -m window",
    screenshot_region  = "hyprshot -m region"
}
