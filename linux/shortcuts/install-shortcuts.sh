DOT="$HOME/.dotfiles"

chmod +x $DOT/linux/shortcuts/esoui-minion.desktop
chmod +x $DOT/linux/shortcuts/fate-stay-night.desktop
chmod +x $DOT/linux/shortcuts/tamrieltradecentre.desktop

ln -s $DOT/linux/shortcuts/esoui-minion.desktop $HOME/.local/share/applications/
ln -s $DOT/linux/shortcuts/fate-stay-night.desktop $HOME/.local/share/applications/
ln -s $DOT/linux/shortcuts/tamrieltradecentre.desktop $HOME/.local/share/applications/

#sudo flatpak override com.usebottles.bottles --filesystem=/home/nalsai/Apps/Bottles
#ln -s /home/nalsai/Sync/Files/Documents/faterealtanua_savedata "/home/nalsai/Apps/Bottles/Fate Stay Night/faterealtanua_savedata"

