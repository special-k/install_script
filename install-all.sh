#!/bin/zsh
ruby='1.9.3'
#mapserver='mapserver-6.0.3'
pgpass='514790'
name='Kirill Jakovlev'
email='special-k@li.ru'
githubuser=$USER
pguser=$USER
if [[ `egrep -o '[0-9]+\.[0-9]+' /etc/issue` > "11.04" ]]
then
  version=new
else
  version=old
fi


show_help() { 
  echo 'You can install:
    chsh
    rsa
    system
    git
    vim
    ruby
    desktop
    postgres
    mysql
    gis
    mapscript

  usage:
    install-all [ prog1 prog2 ... [--except prog1 prog2 ... ] ]

  examples of usage:
    install-all vim ruby              - this install vim and ruby
    install-all --except vim ruby     - this install all except vim and ruby
    install-all                       - this install all'
 }


case $1 in
  --except) b=false
    ;;
  -ex) b=false
    ;;
  --help) 
      show_help
      exit 0
    ;;
  -h) 
      show_help
      exit 0
    ;;
  ?) 
      b=true
    ;;
esac

if [ -z $1 ]
then
  not_b=true
else
  not_b=false
fi

chsh=$not_b
rsa=$not_b
system=$not_b
git=$not_b
vim=$not_b
ruby=$not_b
desktop=$not_b
postgres=$not_b
mysql=$not_b
gis=$not_b
qgis=$not_b
mapserver=$not_b

for i in $*
do
  case $i in
    chsh) chsh=$b
      ;;
    rsa) rsa=$b
      ;;
    system) system=$b
      ;;
    git) git=$b
      ;;
    vim) vim=$b
      ;;
    ruby) ruby=$b
      ;;
    desktop) desktop=$b
      ;;
    postgres) postgres=$b
      ;;
    mysql) mysql=$b
      ;;
    gis) gis=$b
      ;;
    qgis) qgis=$b
      ;;
    mapserver) mapserver=$b
      ;;
  esac
done

cd ~
#sudo
sudo echo We are sudo

#set shell
if $chsh;then
  chsh -s /bin/zsh
fi

#gen rsa
if $rsa;then
  ssh-keygen -t rsa
fi

# update & upgrade
sudo apt-get update
sudo apt-get dist-upgrade -y

#system
if $system;then
  rm -rf .oh-my-zsh #clean
  rm -f .zshrc #clean
  sudo apt-get install -y curl git-core mercurial
  git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  curl https://raw.github.com/Talleyran/install_script/master/files/special_dallas.zsh-theme > .oh-my-zsh/themes/special_dallas.zsh-theme
  curl https://raw.github.com/Talleyran/install_script/master/files/.zshrc > .zshrc
fi

#git
if $git;then
  git config --global --replace-all user.name "$name"
  git config --global --replace-all user.email "$email"
  git config --global --replace-all github.user "$githubuser"
fi

#vim
if $vim;then
  rm -rf .vim #clean
  rm -f .vimrc #clean
  rm -f .iabbrev #clean
  rm -f .ctags #clean
  sudo apt-get install -y vim-gnome
  git clone git@github.com:Talleyran/myvim.git ~/.vim
  cd ~/.vim
  git submodule init
  git submodule update
  ln -s ~/.vim/.vimrc ~/
  ln -s ~/.vim/.iabbrev ~/
  ln -s ~/.vim/.ctags ~/
  ln -s ~/.vim/vim-pathogen/autoload ~/.vim/autoload
  cd ~
fi

#ruby
if $ruby;then
  rm -rf .rvm #clean
  sudo apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion libmagickwand-dev
  bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
  source ~/.zshrc
  rvm install $ruby
  rvm use $ruby --default
  gem install bundler
fi

#desktop
if $desktop;then
  sudo apt-get install -y xclip vlc
  sudo apt-get purge -y totem banshee
  if [[ $version = new ]]
  then
    sudo add-apt-repository -y ppa:alexey-smirnov/deadbeef
    sudo add-apt-repository -y ppa:atareao/atareao
  else
    sudo add-apt-repository ppa:alexey-smirnov/deadbeef
    sudo add-apt-repository ppa:atareao/atareao
  fi
  sudo apt-get update
  sudo apt-get install -y deadbeef touchpad-indicator
fi

#postgres
if $postgres;then
  sudo apt-get install -y postgresql pgadmin3
  sudo -u postgres createuser -s special-k
  sudo -u postgres psql -c "alter role \"$pguser\" password '$pgpass';"
fi

#mysql
if $mysql;then
  sudo apt-get install -y mysql-server libmysqlclient15-dev
fi

#gis
if $gis;then
  if [[ $version = new ]]
  then
    sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
  else
    sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
  fi
  sudo apt-get update
fi

#qgis
if $qgis;then
  sudo apt-get install -y qgis
fi

#postgis
if $postgis;then
  #TODO
fi

#mapserver
if $mapserver;then
  sudo apt-get install -y mapserver-bin libmapscript-ruby1.9.1

  for i in $(ruby -e 'puts $LOAD_PATH')
  do
    for j in $(find $i -maxdepth 1 -name '*.so')
    do
      for k in $(dpkg -L libmapscript-ruby1.9.1 | grep 'mapscript.so')
      do
        cp $k $i/
        chmod +x $i/mapscript.so
        break
      done
      break
    done
  done

  #for i in $(ruby -e 'puts $LOAD_PATH');
  #do
    #ls $i/*.so
  #done

  #cd ~
  #sudo apt-get install -y libfreetype6-dev libgif-dev libpng-dev libjpeg-dev libgdal-dev libgd2-xpm-dev libproj-dev libxslt-dev libghc6-cairo-dev swig
  #rm -rf source/$mapserver
  #rm -f source/$mapserver.tar.gz
  #if [ ! -d ~/source ]; then
    #mkdir ~/source
  #fi
  #cd ~/source
  #curl http://download.osgeo.org/mapserver/$mapserver.tar.gz > $mapserver.tar.gz
  #tar xvzf $mapserver.tar.gz
  #cd $mapserver
  #./configure --libdir=/usr/lib/x86_64-linux-gnu \
  #--with-gdal=/usr/bin/gdal-config \
  #--with-ogr=/usr/bin/gdal-config \
  #--with-wfsclient \
  #--with-wmsclient \
  #--with-curl-config=/usr/bin/curl-config \
  #--with-proj=/usr/ \
  #--with-tiff \
  #--with-jpeg \
  #--with-freetype=/usr/ \
  #--with-threads \
  #--with-wcs \
  #--with-postgis=yes \
  #--with-libiconv=/usr \
  #--with-geos=/usr/bin/geos-config \
  #--with-xml2-config=/usr/bin/xml2-config \
  #--with-sos \
  #--without-agg-svg-symbols \
  #--with-cairo=yes \
  #--with-kml=yes \
  #--with-gd=/usr/lib/x86_64-linux-gnu
  #make
  #cd mapscript/ruby
  #ruby ./extconf.rb
  #make
  #for i in $(ruby -e 'puts $LOAD_PATH')
  #do
    #for j in $(find $i -maxdepth 1 -name '*.so')
    #do
      #cp *.so $i/
      #break
    #done
  #done
  #cd ~
fi

#autoclean
sudo apt-get autoclean
