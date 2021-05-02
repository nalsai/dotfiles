default: config git gtk vim xorg zsh

all: config bash git gtk vim xorg zsh

git: config
	stow -R git

vim: config
	[ -d ~/.vim ] || mkdir ~/.vim
	stow -R vim

chrome: config
	chmod +x _linux/chrome/dark_mode.sh
	./_linux/chrome/dark_mode.sh -f

config: .stowrc

.stowrc:
	echo "--target=${HOME}" > .stowrc

