cd ~
for L in "dotfiles/vimrc .vimrc" \
	"dotfiles/bashrc.d .bashrc.d" \
	"dotfiles/alacritty .config/alacritty" \
	"dotfiles/hypr .config/hypr" \
	"dotfiles/rofi .config/rofi" \
	"dotfiles/swaync .config/swaync" \
	"dotfiles/waybar .config/waybar" \
	"dotfiles/tmux.conf .tmux.conf" \
; do
	read -r source target <<< "$L"
	[ -e "$target" ] && continue
	ln -rs "$source" "$target"
done
