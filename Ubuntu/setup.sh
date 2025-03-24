#!/bin/bash
# ------------------------------------------------------------------------------------------- #
#                                     Ubuntu Setup Script                                     #
# ------------------------------------------------------------------------------------------- #
set -e

# ---------------------------------------- Parameters --------------------------------------- #
git_user=""
git_email=""
git_credencial=""
python="3.13"
dotnet="9"
java="24"
disable_ui=false

for arg in "$@"; do
    case $arg in
        --git_user=*) git_user="${arg#*=}" ;;
        --git_email=*) git_email="${arg#*=}" ;;
        --git_credencial=*) git_credencial="${arg#*=}" ;;
        --python=*) python="${arg#*=}" ;;
        --dotnet=*) dotnet="${arg#*=}" ;;
        --java=*) java="${arg#*=}" ;;
        --noui) disable_ui=true ;;
        --help)
            echo "Usage: ./setup.sh [--git_user=...] [--git_email=...] [--git_credencial=...] [--python=...] [--dotnet=...] [--java=...] [--noui]"
            exit 0
            ;;
        *)
            echo "[!] Unknown option: $arg"
            exit 1
            ;;
    esac
done

# ---------------------------------------- Functions ---------------------------------------- #
install_git() {
    echo "[*] Installing Git..."

    sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get install git -y

    if [[ -n "$git_user" ]]; then
        git config --global user.name "$git_user"
    fi

    if [[ -n "$git_email" ]]; then
        git config --global user.email "$git_email"
    fi

    if [[ -n "$git_credencial" ]]; then
        git config --global credential.helper "$git_credencial"
    fi

    echo "[*] Installing Git LFS..."

    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install git-lfs
    git-lfs install

    echo "[✔] Success"
}

install_font() {
    echo "[*] Installing Fira Code Nerd Font..."

    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip \
    && cd ~/.local/share/fonts \
    && unzip FiraCode.zip \
    && rm FiraCode.zip \
    && fc-cache -fv

    cd ~
    echo "[✔] Success"
}

install_zsh() {
    echo "[*] Installing Oh My Posh..."

    if [ "$disable_ui" = false ]; then
        install_font
    fi

    if [[ ! -f "/usr/local/bin/oh-my-posh" ]]; then
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
        mkdir ~/.poshthemes
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
        unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
        chmod u+rw ~/.poshthemes/*.omp.*
        rm ~/.poshthemes/themes.zip
    fi

    if ! grep -q "oh-my-posh init zsh" ~/.zshrc; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

        echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/craver.omp.json)"' >> ~/.zshrc
        echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
        source ~/.zshrc
    fi

    echo "[✔] Success"
}

install_nvm() {
    echo "[*] Installing NVM..."
    
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
    source ~/.zshrc

    echo "[✔] Success"
}

install_python() {
    echo "[*] Installing Python..."
    
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update

    if [[ -n "$python" ]]; then
        sudo apt install python"$python"
        sudo apt install python3-pip
        sudo apt install python"$python"-venv
        sudo ln -s /usr/bin/python"$python" /usr/bin/python
    else
        sudo apt install python3.13
        sudo apt install python3-pip
        sudo apt install python3.13-venv
        sudo ln -s /usr/bin/python3.13 /usr/bin/python
    fi

    echo "[✔] Success"
}

install_dotnet() {
    echo "[*] Installing .NET..."
    
    wget https://dot.net/v1/dotnet-install.sh
    sudo chmod +x ./dotnet-install.sh

    if [[ -n "$dotnet" ]]; then
        ./dotnet-install.sh --channel "$dotnet".0 
    else
        ./dotnet-install.sh --channel 9.0 
    fi

    echo 'export PATH="$PATH:$HOME/.dotnet/"' >> ~/.zshrc
    echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.zshrc
    echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.zshrc
    source ~/.zshrc
    dotnet tool install --global dotnet-ef

    echo "[✔] Success"
}

install_java() {
    echo "[*] Installing Java..."

    if [[ -n "$java" ]]; then
        wget https://download.oracle.com/java/"$java"/latest/jdk-"$java"_linux-x64_bin.deb
        sudo dpkg -i jdk-"$java"_linux-x64_bin.deb
    else
        wget https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.deb
        sudo dpkg -i jdk-24_linux-x64_bin.deb
    fi

    JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which javac))))
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.zshrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.zshrc
    source ~/.zshrc

    echo "[✔] Success"
}

# install_docker() {
#     echo "[*] Installing Docker..."

#     sudo apt-get remove docker docker-engine docker.io containerd runc
#     sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
#     sudo rm -rf /var/lib/docker
#     sudo rm -rf /var/lib/containerd
#     sudo apt-get install -y ca-certificates curl gnupg
#     sudo install -m 0755 -d /etc/apt/keyrings
#     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#     sudo chmod a+r /etc/apt/keyrings/docker.gpg
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#     sudo apt-get update
#     sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#     sudo groupadd docker || true
#     sudo usermod -aG docker "$USER"

#     echo "[✔] Success"
# }

install_apps() {
    echo "[*] Installing Applicatons..."

    # vscode
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code

    # stremio service
    wget "https://dl.strem.io/stremio-service/v0.1.13/stremio-service_amd64.deb"
    sudo dpkg -i stremio-service_amd64.deb

    # jetbrains toolbox
    sudo apt install libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin
    curl -fsSL https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh | bash

    # rabbitvcs
    sudo apt-get update
    sudo apt install rabbitvcs-core rabbitvcs-cli rabbitvcs-nautilus rabbitvcs-gedit

    echo "[✔] Success"
}

install_flatpack() {
    echo "[*] Installing Flatpack..."

    sudo apt install flatpak
    sudo apt install gnome-software-plugin-flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    echo "[✔] Success"
}

setup_theme() {
    echo "[*] Setting up theme..."

    mkdir -p "$HOME/.themes"

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Themes/Andromeda.zip"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Themes/One%20Dark.zip" -O OneDark.zip
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Wallpaper/Wallpaper.mp4" -O "$HOME/Videos/Wallpaper.mp4"

    unzip Andromeda.zip -d "$HOME/.themes"
    unzip OneDark.zip -d "$HOME/.themes"

    echo "[✔] Success"
}

setup_cursor() {
    echo "[*] Setting up cursor..."

    mkdir -p "$HOME/.icons"

    wget https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Cursor/Bibata-Modern-Ice.zip
    
    unzip Bibata-Modern-Ice.zip -d "$HOME/.icons"

    echo "[✔] Success"
}

setup_browser() {
    echo "[*] Setting up browser..."

    sudo apt update
    sudo apt install -y libfuse2t64

    mkdir -p "$HOME/Zen"

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Browser/zen.AppImage" -O "$HOME/.local/bin/zen.AppImage"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/userChrome.css" -O "$HOME/Zen/userChrome.css"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/Setup.txt" -O "$HOME/Zen/Setup.txt"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Browser/Extensions/Enhancer%20For%20Youtube.xpi" -O "$HOME/Zen/Enhancer For Youtube.xpi"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/Configuration/AdBlocker.txt" -O "$HOME/Zen/AdBlocker.txt"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/Configuration/Enhancer%20for%20Youtube.json" -O "$HOME/Zen/Enhancer for Youtube.json"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Browser/firefox.ico" -O "$HOME/.icons/firefox.ico"

    chmod +x "$HOME/.local/bin/zen.AppImage"
    cat <<EOF > ~/.local/share/applications/zen-browser.desktop
[Desktop Entry]
Name=Zen Browser
Exec=$HOME/.local/bin/zen.AppImage
Icon=$HOME/.icons/firefox.ico
Type=Application
Categories=Network;WebBrowser;
EOF

    echo "[✔] Success"
}

setup_insomnia() {
    echo "[*] Setting up Insomnia..."

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Programs/Insomnia.deb"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Utilities/Insomnia/Insomnia"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Utilities/Insomnia/index.js"

    sudo dpkg -i Insomnia.deb

    echo "[✔] Success"
}

setup_terminal() {
    echo "[*] Setting up terminal..."

    gnome-terminal --geometry=192x26+0+0 &
    wget https://raw.githubusercontent.com/safesintesi/terminal-guillotine/main/guillotine.sh -qO- | bash

    echo "[✔] Success"
}

setup_extensions() {
    echo "[*] Setting up extensions..."

    sudo apt install -y ubuntu-restricted-extras
    sudo apt install git meson
    sudo apt install libgtk-4-media-gstreamer
    sudo apt install gir1.2-gst-plugins-base-1.0 gir1.2-gst-plugins-bad-1.0

    wget https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v68.shell-extension.zip
    wget https://extensions.gnome.org/extension-data/compiz-alike-magic-lamp-effecthermes83.github.com.v21.shell-extension.zip
    wget https://github.com/hardpixel/unite-shell/releases/download/v82/unite-v82.zip
    wget https://extensions.gnome.org/extension-data/transparent-top-barftpix.com.v23.shell-extension.zip
    wget https://extensions.gnome.org/extension-data/hidetopbarmathieu.bidon.ca.v119.shell-extension.zip
    wget https://extensions.gnome.org/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v63.shell-extension.zip
    
    gnome-extensions install compiz-alike-magic-lamp-effecthermes83.github.com.v21.shell-extension.zip
    gnome-extensions install blur-my-shellaunetx.v68.shell-extension.zip
    gnome-extensions install unite-v82.zip
    gnome-extensions install transparent-top-barftpix.com.v23.shell-extension.zip
    gnome-extensions install hidetopbarmathieu.bidon.ca.v119.shell-extension.zip
    gnome-extensions install user-themegnome-shell-extensions.gcampax.github.com.v63.shell-extension.zip

    git clone https://github.com/jeffshee/gnome-ext-hanabi.git -b gnome-47
    cd gnome-ext-hanabi
    ./run.sh install
    cd ..

    echo "[✔] Success"
}

setup_ui() {
    echo "[*] Setting up UI..."

    sudo apt install gnome-software
    sudo apt install gnome-shell-extension-manager
    sudo apt install x11-utils
    sudo apt install dconf-editor
    sudo apt install gnome-tweaks

    setup_theme
    setup_cursor
    setup_browser
    setup_terminal
    setup_extensions

    install_flatpack
    install_apps

    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/DConf/dconf-settings.ini"
    dconf load / < dconf-settings.ini

    echo "[✔] Success"
}

# ---------------------------------------- Execution ---------------------------------------- #
for arg in "$@"; do
    if [[ "$arg" == "--noui" ]]; then
        disable_ui=true
    fi
done

echo "[*] Updating system..."

sudo apt update && sudo apt upgrade -y

install_git
install_zsh
install_nvm
install_python
install_dotnet
install_java
# install_docker

if [ "$disable_ui" = false ]; then
    setup_ui
else
    echo "[*] Skipping UI setup due to --noui flag"
fi

echo "[✔] Setup complete! Restart your computer for changes to take effect."
