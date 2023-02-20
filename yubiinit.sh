if [ "$(type -t yubisetup)" != "function" ] && [ ! -e $HOME/.yubikey.sh ]
then
cp  $BASH_SOURCE $HOME/.yubikey.sh
echo $(basename $SHELL)
  case $(basename $SHELL) in
    bash)
      echo "source .yubikey.sh" >> $HOME/.bashrc && echo "updated .bashrc"
      . $HOME/.yubikey.sh && echo "load $HOME/.yubikey.sh"
      yubisetup
      ;;
    zsh)
      echo "source .yubikey.sh" >> $HOME/.zshrc && echo "updated .zshrc"
      source $HOME/.yubikey.sh && echo "load $HOME/.yubikey.sh"
      yubisetup
      ;;
    *)
      echo "tundmatu shell"
    esac
fi

function yubisetup {
  if [ -L /usr/local/lib/libykcs11.dylib ]
  then
    sudo rm /usr/local/lib/libykcs11.dylib
  fi
  libfile=$(find /usr/local -name libykcs11.dylib ! -path '/usr/local/lib/*')
  if [ -z "$libfile" ]
  then
      echo "libykcs11.dylib puudub, paigaldme 'brew install yubico-piv-tool'"
      brew install yubico-piv-tool
      libfile=$(find /usr/local -name libykcs11.dylib ! -path '/usr/local/lib/*')
      sudo cp $libfile /usr/local/lib/libykcs11.dylib
      echo "Setup done"
  elif [ $(echo $libfile | wc -w) -gt 1 ]
  then
      echo "libykcs11.dylib faile leiti rohkem kui 1, vali:"
      select lib in ${libfile[@]}
      do
        selected_libfile=$lib
        break
      done
      sudo cp $selected_libfile /usr/local/lib/libykcs11.dylib
  elif diff -b $libfile /usr/local/lib/libykcs11.dylib > /dev/null 2>&1
  then
    echo "setup is ok"
  else
    echo "update file"
    sudo cp $selected_libfile /usr/local/lib/libykcs11.dylib
  fi
}

PID=$(awk -F '[ ;]' '/pid/ {print $4}'  ~/.ssh/yubiagent.sh)
if ps -p $PID > /dev/null
then
  source $HOME/.ssh/yubiagent.sh
fi

alias yubiinit='pkill ssh-agent; /usr/bin/ssh-agent -s > $HOME/.ssh/yubiagent.sh; source $HOME/.ssh/yubiagent.sh; ssh-add -s /usr/local/lib/libykcs11.dylib'
alias yubiload='source $HOME/.ssh/yubiagent.sh'

