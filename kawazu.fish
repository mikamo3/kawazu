#!/usr/bin/env fish
set fish_trace 1
function kawazu
  set kawazu_root_dir
  set kawazu_dotfiles_dir
  if [ "{$KAWAZU_ROOT_DIR}" = "" ]
    set kawazu_root_dir {$HOME}/.kawazu/repos
    else
    set kawazu_root_dir {$KAWAZU_ROOT_DIR}
  end
  if [ "{$KAWAZU_DOTFILES_DIR}" = "" ]
    set kawazu_dotfiles_dir {$HOME}/.kawazu/dotfiles
    else
    set kawazu_dotfiles_dir {$KAWAZU_DOTFILES_DIR}
  end
  if [ "$argv[1]" = "cd" ]
    cd {$kawazu_dotfiles_dir}
  else
    {$kawazu_root_dir}/bin/kawazu $argv
  end
end
kawazu cd