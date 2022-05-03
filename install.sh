#!/bin/bash

echo "got arguments $@"

usage() {
  printf "Usage: $0 [-a :all] [-b :browsers] [-u :utilities] [-e editors] [-p :preflight] [-c :container tools] [-x :xcode] [-m :python modules] \n"
  exit 1
}

all="false"
browsers="false"
container="false"
editors="false"
preflight="false"
utilities="false"
xcode="false"
pythonmods="false"

while getopts abuecpxa: opt; do
  case ${opt} in
    a)
      all="true"
      ;;
    b)
      browsers="true"
      ;;
    c)
      container="true"
      ;;
    e)
      editors="true"
      ;;
    p)
      preflight="true"
      ;;
    u)
      utilities="true"
      ;;
    x)
      xcode="true"
      ;;
    m)
      pythonmods="true"
      ;;
  esac
done

rm -rf ./download
mkdir -p ./download/tmp

install() {
  pushd ./download/tmp > /dev/null || return 
  sudo mv *.app /Applications/
  popd > /dev/null || return
}

preflight() {
  echo "Checking for prerequsites..."
  ## XCode commandline tools
  if [ ! -d /Library/Developer/CommandLineTools ]; then
    /usr/sbin/softwareupdate -i Command\ Line\ Tools\ for\ Xcode-13.3
  fi
    
  ## Homebrew
  if [ ! -f "/usr/local/bin/brew" ]; then
    echo "Installing Homebrew and bundles..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle
  else
    echo "Installing brew bundles..."
    brew bundle
  fi
  
  ## oh-my-zsh
  if [ -d ~/.oh-my-zsh ]; then
	echo "oh-my-zsh is already installed"
  else
   echo "Installing oh-my-zsh..."
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

}

editors() {
  pushd ./download > /dev/null || return
  ## Atom
  if [ ! -d "/Applications/Atom.app" ]; then
    echo "Installing Atom..."
    $(curl -fsL -o atom-mac.zip 'https://atom.io/download/mac')
    unzip -q atom-mac.zip -d ./tmp/
    install
  fi

  ## VSCode
  if [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "Installing VSCode..."  
    $(curl -fsL -o VSCode.zip 'https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal')
    unzip -q VSCode.zip -d ./tmp/
    install
  fi

  ## PyCharm
  if [ ! -d "/Applications/PyCharm CE.app" ]; then
    echo "Installing PyCharm CE..."
    PYCHARM_VERSION=2021.3.3
    $(curl -fsL -o pycharm-community-${PYCHARM_VERSION}.dmg https://download.jetbrains.com/python/pycharm-community-${PYCHARM_VERSION}.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./pycharm-community-${PYCHARM_VERSION}.dmg
    cp -R /Volumes/PyCharm*/*.app ./tmp/
    hdiutil detach -quiet /Volumes/PyCharm*
    install
  fi

  ## Thonny
  if [ ! -d "/Applications/Thonny.app" ]; then
    echo "Installing Thonny..."
    THONNY_VERSION=3.3.13
    $(curl -fsL -o thonny-${THONNY_VERSION}.pkg https://github.com/thonny/thonny/releases/download/v${THONNY_VERSION}/thonny-${THONNY_VERSION}.pkg)
    sudo installer -pkg ./thonny-${THONNY_VERSION}.pkg -target /
    install
  fi
  
  popd > /dev/null || return
}

browsers() {
  pushd ./download > /dev/null || return    
  ## Firefox
  if [ ! -d "/Applications/Firefox.app" ]; then
    echo "Installing Firefox..."
    $(curl -fsL -o Firefox.dmg 'https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US')
    hdiutil attach -noautoopen -noverify -quiet ./Firefox.dmg
    cp -R /Volumes/Firefox/*.app ./tmp/
    hdiutil detach -quiet /Volumes/Firefox
  fi

  ## Chrome
  if [ ! -d "/Applications/Google Chrome.app" ]; then
    echo "Installing Google Chrome..."  
    $(curl -fsL -o googlechrome.dmg 'https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg')
    hdiutil attach -noautoopen -noverify -quiet ./googlechrome.dmg
    cp -R /Volumes/Google\ Chrome/*.app ./tmp/
    hdiutil detach -quiet /Volumes/Google\ Chrome
    install
  fi

  popd > /dev/null || return
}

container() {
  pushd ./download > /dev/null || return
  ## Docker
  if [ ! -d "/Applications/Docker.app" ]; then
    echo "Installing Docker..."
    $(curl -fsL -o Docker.dmg 'https://desktop.docker.com/mac/main/amd64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-amd64')
    hdiutil attach -noautoopen -noverify -quiet ./Docker.dmg
    cp -R /Volumes/Docker/*.app ./tmp/
    hdiutil detach -quiet /Volumes/Docker
    install
  fi

  ## Rancher Desktop
  if [ ! -d "/Applications/Rancher Desktop.app" ]; then
    echo "Installing Rancher Desktop..."
    RANCHER_VERSION=1.2.1
    $(curl -fsL -o Rancher.Desktop-${RANCHER_VERSION}.x86_64.dmg https://github.com/rancher-sandbox/rancher-desktop/releases/download/v${RANCHER_VERSION}/Rancher.Desktop-${RANCHER_VERSION}.x86_64.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./Rancher.Desktop-${RANCHER_VERSION}.x86_64.dmg
    cp -R /Volumes/Rancher*/*.app ./tmp/
    hdiutil detach -quiet /Volumes/Rancher*
    install
  fi

  ## Lens
  if [ ! -d "/Applications/Lens.app" ]; then
    echo "Installing Lens..."
    $(curl -fsL -o lens.dmg 'https://api.k8slens.dev/binaries/latest.dmg')
    hdiutil attach -noautoopen -noverify -quiet ./lens.dmg
    cp -R /Volumes/Lens*/*.app ./tmp/
    hdiutil detach -quiet /Volumes/Lens*
    install
  fi
  popd > /dev/null || return    
}

utilities() {
  pushd ./download > /dev/null || return

  ## Angry IP Scanner
  if [ ! -d "/Applications/Angry IP Scanner.app" ]; then
    echo "Installing Angry IP Scanner..."
    ANGRYIP_VERSION=3.8.2
    $(curl -fsSL -o ipscan-macx86-${ANGRYIP_VERSION}.zip https://github.com/angryip/ipscan/releases/download/${ANGRYIP_VERSION}/ipscan-macX86-${ANGRYIP_VERSION}.zip)
    unzip -q ipscan-macx86-${ANGRYIP_VERSION}.zip -d ./tmp/
    install
  fi

  ## Caffeine
  if [ ! -d "/Applications/Caffeine.app" ]; then
    echo "Installing Caffeine..."
    CAFFEINE_VERSION=1.1.3
    $(curl -fsL -o Caffeine.dmg https://github.com/IntelliScape/caffeine/releases/download/${CAFFEINE_VERSION}/Caffeine.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./Caffeine.dmg
    cp -R /Volumes/Caffeine/*.app ./tmp/
    hdiutil detach -quiet /Volumes/Caffeine
    install
  fi

  ## Spectacle
  if [ ! -d "/Applications/Spectacle.app" ]; then 
    echo "Installing Spectacle..."
    SPECTACLE_VERSION=1.2
    $(curl -fsL -o Spectacle+${SPECTACLE_VERSION}.zip https://github.com/eczarny/spectacle/releases/download/${SPECTACLE_VERSION}/Spectacle+${SPECTACLE_VERSION}.zip)
    unzip -q Spectacle+${SPECTACLE_VERSION}.zip -d ./tmp/
  fi

  ## iTerm2
  if [ ! -d "/Applications/iTerm.app" ]; then
    echo "Installing iTerm2..."
    ITERM_VERSION=3_4_15
    $(curl -fsL -o iTerm2-${ITERM_VERSION}.zip https://iterm2.com/downloads/stable/iTerm2-${ITERM_VERSION}.zip)
    unzip -q iTerm2-${ITERM_VERSION}.zip -d ./tmp/
  fi

  ## LastPass
  if [ ! -d "/Applications/LastPass.app" ]; then
    echo "Installing LastPass..."
    $(curl -fsL -o LastPass.dmg 'https://lastpass.com/safariAppExtension.php?source=download')
    hdiutil attach -noautoopen -noverify -quiet ./LastPass.dmg
    cp -R /Volumes/LastPass*/*.app ./tmp/
    hdiutil detach -quiet /Volumes/LastPass*
  fi

  ## unetbootin
  if [ ! -d "/Applications/unetbootin.app" ]; then
    echo "Installing UNetbootin... "
    UNETBOOTIN_VERSION=702
    $(curl -fsL -o unetbootin-mac-${UNETBOOTIN_VERSION}.dmg https://github.com/unetbootin/unetbootin/releases/download/${UNETBOOTIN_VERSION}/unetbootin-mac-${UNETBOOTIN_VERSION}.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./unetbootin-mac-${UNETBOOTIN_VERSION}.dmg
    cp -R /Volumes/UNetbootin*/*.app ./tmp/
    hdiutil detach -quiet /Volumes/UNetbootin*
    install
  fi

  ## MQTT Explorer
  if [ ! -d "/Applications/MQTT Explorer.app" ]; then
    echo "Installing MQTT Explorer..."
    MQTT_VERSION=0.3.5
    $(curl -fsL -o MQTT-Explorer-${MQTT_VERSION}.dmg https://github.com/thomasnordquist/MQTT-Explorer/releases/download/v${MQTT_VERSION}/MQTT-Explorer-${MQTT_VERSION}.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./MQTT-Explorer-${MQTT_VERSION}.dmg
    cp -R /Volumes/MQTT*/*.app ./tmp/
    hdiutil detach -quiet /Volumes/MQTT*
    install
  fi

  ## VeraCrypt
  if [ ! -d "/Applications/VeraCrypt.app" ]; then
    echo "Installing macFUSE..."
    FUSE_VERSION=4.2.4
    $(curl -fsL -o macfuse-${FUSE_VERSION}.dmg https://github.com/osxfuse/osxfuse/releases/download/macfuse-${FUSE_VERSION}/macfuse-${FUSE_VERSION}.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./macfuse-${FUSE_VERSION}.dmg
    cp -R /Volumes/macFUSE/Extras/*.pkg ./
    hdiutil detach -quiet /Volumes/macFUSE
    sudo installer -pkg macFUSE\ ${FUSE_VERSION}.pkg -target /
    
    echo "Installing VeraCrypt..."
    VERACRYPT_VERSION=1.25.9
    $(curl -fsL -o VeraCrypt_${VERACRYPT_VERSION}.dmg https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/VeraCrypt_${VERACRYPT_VERSION}.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./VeraCrypt_${VERACRYPT_VERSION}.dmg
    cp -R /Volumes/VeraCrypt*/*.pkg ./
    hdiutil detach -quiet /Volumes/VeraCrypt*
    sudo installer -pkg ./VeraCrypt_Installer.pkg -target /
  fi

  ## VLC
  if [ ! -d "/Applications/VLC.app" ]; then
    echo "Installing VLC..."
    VLC_VERSION=3.0.16
    $(curl -fsL -o vlc-${VLC_VERSION}-intel64.dmg https://get.videolan.org/vlc/${VLC_VERSION}/macosx/vlc-${VLC_VERSION}-intel64.dmg)
    hdiutil attach -noautoopen -noverify -quiet ./vlc-${VLC_VERSION}-intel64.dmg
    cp -R /Volumes/VLC*/*.app ./tmp/
    hdiutil detach -quiet /Volumes/VLC*
    install
  fi

  ## Slack
  if [ ! -d "/Applications/Slack.app" ]; then
  echo "Installing Slack..."
  SLACK_VERSION=4.25.0
  mas install 803453959
  
  ## Speedtest
  if [ ! -d "/Applications/Speedtest.app" ]; then
  echo "Installing SpeedTest..."
  SLACK_VERSION=1.24
  mas install 1153157709
  
  popd > /dev/null || return   
}

xcode() {
  ## XCode
  echo "Installing XCode..."
  if [ ! -d "/Applications/Xcode.app/Contents/Developer" ]; then
    mas install 497799835
  fi
}

pythonmods() {
  ## Install common python3 modules
  pip3 install -r requirements.txt
}

if [[ $preflight == "true" ]]; then
  preflight
  exit 1
fi

if [[ $editors == "true" ]]; then
  editors
  exit 1
fi

if [[ $browsers == "true" ]]; then
  browsers
  exit 1
fi

if [[ $container == "true" ]]; then
  container
  exit 1
fi

if [[ $utilities == "true" ]]; then
  utilities
  exit 1
fi

if [[ $xcode == "true" ]]; then
  xcode
  exit 1
fi

if [[ $all == "true" ]]; then
  preflight
  editors
  browsers
  container
  utilities
  xcode
  pythonmods
  exit 1
fi
