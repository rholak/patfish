function pat -d "Aptitude with more aptitude"
  set cmd help

  if [ (count $argv) -gt 0 ]
    set cmd $argv[1]

    # The following implements shift to pop off argv[1]
    if [ (count $argv) -gt 1 ]
      set argv $argv[2..-1]
    else
      set -e argv[1]
    end
  end

function _pat-su
  if [ "$USER" != "root" ]
    sudo -- $argv
  else 
    eval $argv
  end
end


  # Because the original has it ;)
  if [ $cmd = "moo" ]
    if [ (count $argv) -eq 0 ]
      echo "I'm an elephant."
    else
      echo "I'm not an elephant?"
    end
    return
  end

  functions -q "_pat-$cmd"
  if [ $status -eq 0 ]
    eval _pat-$cmd $argv
  else
    _pat-su aptitude $cmd $argv
  end
end

function _pat-help
  echo "\
  Usage:
    pat <command> [args]

  Commands:
    help                        Display this help
    up                          Alias for pat update && pat upgrade
    u,update                    Update package lists and contents [aptitude,apt-file]
    upgrade                     Perform an upgrade [aptitude]
    ui                          Open a ncurses UI for managing packages [aptitude]
    i,install <package...|file> Install a single .deb, or list of packages [dpkg,apt-get,aptitude]
    file <action> [pattern...]  Wrapper around apt-file [apt-file]
    ppa <ppa>                   Shorthand for adding a PPA [apt-add-repository]
    add,add-repository <repo>   Add a repository [add-apt-repository]
    reconfigure <package...>    Reconfigure packages [dpkg-reconfigure]
    search <pattern...>         Search for a package by name and/or pattern [aptitude]
    find <pattern...>           Search files in packages by pattern [apt-file]
    show <package>              Display detailed information about a package [aptitude]
    autoremove                  Automatically remove all unused packages [apt-get]

  If a command does not match the list above, it is passed directly to aptitude.

  This patpat does not yet have supercow powers.
  "
end

function _pat-ui 
  _pat-su aptitude
end

function _pat-search; aptitude search $argv; end
function _pat-show; aptitude show $argv; end

function _pat-i; _pat-install $argv; end
function _pat-install 
  if [ test -f $argv[1] ]
    _pat-su dpkg -i $argv[1]
    _pat-su apt-get -f install
  else
    _pat-su aptitude install $argv
  end
end

function _pat-up 
  _pat-update
  _pat-su aptitude upgrade
end

function _pat-u; _pat-update $argv; end
function _pat-update 
  _pat-su aptitude update
  _pat-su apt-file update
end

function _pat-reconfigure 
  _pat-su dpkg-reconfigure $argv
end

function _pat-add; _pat-add-repository $argv; end
function _pat-add-repository 
  _pat-su add-apt-repository $argv[1]
  _pat-update
end

function _pat-ppa 
  _pat-add-repository ppa:$argv[1]
end

function _pat-find 
  apt-file find $argv
end

function _pat-file 
  _pat-su apt-file $argv
end

function _pat-autoremove
  _pat-su apt-get autoremove $argv
end
