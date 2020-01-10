(windows) symlink `_vimrc` to base vim installation directory (e.g., c:\vim, not c:\vim\vim82).
symlink `_vimrc` to `~/.vim/.vimrc`
`mkdir $VIMRUNTIME/temp` where `VIMRUNTIME` is e.g. c:\vim\vim82.
copy subdirectories to vim installation directory.
mkdir ~/.vim/bundle
`git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim`
Launch vim and run `:PluginInstall`
