#!/usr/bin/env fish
function kawazu
  set kawazu_root_dir
  if [ "{$KAWAZU_ROOT_DIR}" = "" ]
    set kawazu_root_dir {$HOME}/.kawazu/repos
    else
    set kawazu_root_dir {$KAWAZU_ROOT_DIR}
  end
  if [ "{$argv}" = "cd" ]
    {$kawazu_root_dir}/bin/kawazu cd
  else
    {$kawazu_root_dir}/bin/kawazu $argv
  end
end