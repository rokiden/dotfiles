cd ~
for L in "dotfiles/vimrc .vimrc" \
	"dotfiles/bashrc.d .bashrc.d" \
	"dotfiles/alacritty .config/alacritty" \
	"dotfiles/hypr .config/hypr" \
	"dotfiles/rofi .config/rofi" \
	"dotfiles/swaync .config/swaync" \
	"dotfiles/waybar .config/waybar" \
; do
	read -r source target <<< "$L"
	ln -rs "$source" "$target"
done
