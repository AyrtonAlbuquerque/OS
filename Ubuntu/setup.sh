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

# ----------------------------------------- Markers ----------------------------------------- #
MARKERS="$HOME/.setup-markers"
mkdir -p "$MARKERS"

executed() {
    [[ -f "$MARKERS/$1" ]]
}

finished() {
    touch "$MARKERS/$1"
}

cleanup() {
    echo "[*] Cleaning up marker files..."
    rm -rf "$MARKERS"
    echo "[✔] Markers cleared"
}

trap 'echo "[!] Script interrupted. Partial state saved in $MARKERS"' ERR
trap cleanup EXIT

# ---------------------------------------- Functions ---------------------------------------- #
install_git() {
    if executed "install_git"; then
        echo "[✔] Git already installed, skipping"
        return
    fi

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
    sudo apt-get install git-lfs -y
    git-lfs install

    finished "install_git"
    echo "[✔] Success"
}

install_font() {
    if executed "install_font"; then
        echo "[✔] Font already installed, skipping"
        return
    fi

    echo "[*] Installing Fira Code Nerd Font..."

    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip \
    && cd ~/.local/share/fonts \
    && unzip FiraCode.zip \
    && rm FiraCode.zip \
    && fc-cache -fv

    cd ~
    finished "install_font"
    echo "[✔] Success"
}

install_zsh() {
    if executed "install_zsh"; then
        echo "[✔] ZSH already installed, skipping"
        return
    fi

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

    finished "install_zsh"
    echo "[✔] Success"
}

install_nvm() {
    if executed "install_nvm"; then
        echo "[✔] NVM already installed, skipping"
        return
    fi

    echo "[*] Installing NVM..."
    
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
    source ~/.zshrc

    finished "install_nvm"
    echo "[✔] Success"
}

install_python() {
    if executed "install_python"; then
        echo "[✔] Python already installed, skipping"
        return
    fi

    echo "[*] Installing Python..."

    if lsb_release -d | grep -q "LTS"; then
        {
            sudo add-apt-repository ppa:deadsnakes/ppa -y
            sudo apt update &&
        } || {
            echo "[!] Failed to install Python. Most likely reason is that your distribution is not supported by the deadsnakes PPA."
            sudo add-apt-repository --remove ppa:deadsnakes/ppa -y
            sudo apt update
        }
    fi

    if [[ -n "$python" ]]; then
        sudo apt install python"$python" -y
        sudo apt install python3-pip -y
        sudo apt install python"$python"-venv -y
        sudo ln -s /usr/bin/python"$python" /usr/bin/python
    else
        sudo apt install python3.13 -y
        sudo apt install python3-pip -y
        sudo apt install python3.13-venv -y
        sudo ln -s /usr/bin/python3.13 /usr/bin/python
    fi

    finished "install_python"
    echo "[✔] Success"
}

install_dotnet() {
    if executed "install_dotnet"; then
        echo "[✔] .NET already installed, skipping"
        return
    fi

    echo "[*] Installing .NET..."
    
    wget https://dot.net/v1/dotnet-install.sh -O .dotnet-install.sh
    sudo chmod +x ./.dotnet-install.sh

    if [[ -n "$dotnet" ]]; then
        ./.dotnet-install.sh --channel "$dotnet".0
    else
        ./.dotnet-install.sh --channel 9.0
    fi

    echo 'export PATH="$PATH:$HOME/.dotnet/"' >> ~/.zshrc
    echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.zshrc
    echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.zshrc
    source ~/.zshrc
    dotnet tool install --global dotnet-ef

    finished "install_dotnet"
    echo "[✔] Success"
}

install_java() {
    if executed "install_java"; then
        echo "[✔] Java already installed, skipping"
        return
    fi

    echo "[*] Installing Java..."

    if [[ -n "$java" ]]; then
        wget https://download.oracle.com/java/"$java"/latest/jdk-"$java"_linux-x64_bin.deb
        sudo dpkg -i jdk-"$java"_linux-x64_bin.deb
        rm jdk-"$java"_linux-x64_bin.deb
    else
        wget https://download.oracle.com/java/24/latest/jdk-24_linux-x64_bin.deb
        sudo dpkg -i jdk-24_linux-x64_bin.deb
        rm jdk-24_linux-x64_bin.deb
    fi

    JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which javac))))
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.zshrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.zshrc
    source ~/.zshrc

    finished "install_java"
    echo "[✔] Success"
}

install_docker() {
    if executed "install_docker"; then
        echo "[✔] Docker already installed, skipping"
        return
    fi

    echo "[*] Installing Docker..."

    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo groupadd docker || true
    sudo usermod -aG docker "$USER"

    finished "install_docker"
    echo "[✔] Success"
}

install_apps() {
    if executed "install_apps"; then
        echo "[✔] Applications already installed, skipping"
        return
    fi

    echo "[*] Installing Applicatons..."

    # vscode
    sudo apt-get install -y wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https -y
    sudo apt update
    sudo apt install code -y

    # stremio service
    wget "https://dl.strem.io/stremio-service/v0.1.13/stremio-service_amd64.deb"
    sudo dpkg -i stremio-service_amd64.deb
    rm stremio-service_amd64.deb

    # jetbrains toolbox
    sudo apt install -y libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin
    {
        echo "[*] Installing JetBrains Toolbox..."
        curl -fsSL https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Utilities/Toolbox/toolbox-install.sh | bash &&
    } || {
        echo "[!] Failed to install JetBrains Toolbox"
    }

    # rabbitvcs
    sudo apt-get update
    sudo apt install -y rabbitvcs-core rabbitvcs-cli rabbitvcs-nautilus rabbitvcs-gedit

    finished "install_apps"
    echo "[✔] Success"
}

install_flatpack() {
    if executed "install_flatpack"; then
        echo "[✔] Flatpack already installed, skipping"
        return
    fi

    echo "[*] Installing Flatpack..."

    sudo apt install flatpak -y
    sudo apt install gnome-software-plugin-flatpak -y
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    finished "install_flatpack"
    echo "[✔] Success"
}

setup_theme() {
    if executed "setup_theme"; then
        echo "[✔] Theme already installed, skipping"
        return
    fi

    echo "[*] Setting up theme..."

    mkdir -p "$HOME/.themes"

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Themes/Andromeda.zip"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Themes/OneDark.zip" -O OneDark.zip
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Wallpaper/Wallpaper.mp4" -O "$HOME/Videos/Wallpaper.mp4"

    unzip OneDark.zip -d "$HOME/.themes"

    rm OneDark.zip

    finished "setup_theme"
    echo "[✔] Success"
}

setup_cursor() {
    if executed "setup_cursor"; then
        echo "[✔] Cursor already installed, skipping"
        return
    fi

    echo "[*] Setting up cursor..."

    mkdir -p "$HOME/.icons"

    wget https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Cursor/Bibata-Modern-Ice.zip
    
    unzip Bibata-Modern-Ice.zip -d "$HOME/.icons"

    rm Bibata-Modern-Ice.zip

    finished "setup_cursor"
    echo "[✔] Success"
}

setup_browser() {
    if executed "setup_browser"; then
        echo "[✔] Browser already installed, skipping"
        return
    fi

    echo "[*] Setting up browser..."

    sudo apt update
    sudo apt install -y libfuse2t64

    mkdir -p "$HOME/Zen"
    mkdir -p "$HOME/Applications"
    mkdir -p "$HOME/Applications/zen"

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Browser/zen.AppImage" -O "$HOME/Applications/zen/zen.AppImage"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Browser/firefox.png" -O "$HOME/Applications/zen/firefox.png"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/Setup.txt" -O "$HOME/Zen/Setup.txt"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Browser/Extensions/Infinity%20New%20Tab.xpi" -O "$HOME/Zen/Infinity New Tab.xpi"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/Configuration/AdBlocker.txt" -O "$HOME/Zen/AdBlocker.txt"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/Configuration/Enhancer%20for%20Youtube.json" -O "$HOME/Zen/Enhancer for Youtube.json"

    chmod +x "$HOME/Applications/zen/zen.AppImage"
    cat <<-EOF > ~/.local/share/applications/zen.desktop
		[Desktop Entry]
		Name=Zen Browser
		Comment=Experience tranquillity while browsing the web without people tracking you!
		Exec=$HOME/Applications/zen/zen.AppImage %u
		Icon=$HOME/Applications/zen/firefox.png
		Type=Application
		MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;application/x-xpinstall;application/pdf;application/json;
		StartupWMClass=zen-alpha
		Categories=Network;WebBrowser;
		StartupNotify=true
		Terminal=false
		X-MultipleArgs=false
		Keywords=Internet;WWW;Browser;Web;Explorer;
		Actions=new-window;new-private-window;profilemanager;

		[Desktop Action new-window]
		Name=Open a New Window
		Exec=$HOME/Applications/zen/zen.AppImage %u

		[Desktop Action new-private-window]
		Name=Open a New Private Window
		Exec=$HOME/Applications/zen/zen.AppImage --private-window %u

		[Desktop Action profilemanager]
		Name=Open the Profile Manager
		Exec=$HOME/Applications/zen/zen.AppImage --ProfileManager %u
	EOF

    "$HOME/Applications/zen/zen.AppImage" &
    zen_pid=$!
    sleep 5
    kill $zen_pid 2>/dev/null || true
    wait $zen_pid 2>/dev/null || true

    profiles_dir="$HOME/.zen"

    if [[ -d "$profiles_dir" ]]; then
        default_profile=$(find "$profiles_dir" -type d -name "*.default" | head -1)
        
        if [[ -n "$default_profile" ]]; then
            chrome_folder="$default_profile/chrome"
            
            if [[ ! -d "$chrome_folder" ]]; then
                mkdir -p "$chrome_folder"
            fi

            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/userChrome.css" -O "$chrome_folder/userChrome.css"
        else
            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/userChrome.css" -O "$HOME/Zen/userChrome.css"
        fi
    else
        wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Browser/userChrome.css" -O "$HOME/Zen/userChrome.css"
    fi

    finished "setup_browser"
    echo "[✔] Success"
}

setup_insomnia() {
    if executed "setup_insomnia"; then
        echo "[✔] Insomnia already installed, skipping"
        return
    fi

    echo "[*] Setting up Insomnia..."

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Ubuntu/Programs/Insomnia.deb"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/Utilities/Insomnia/Insomnia"

    sudo dpkg -i Insomnia.deb
    rm Insomnia.deb

    finished "setup_insomnia"
    echo "[✔] Success"
}

setup_terminal() {
    if executed "setup_terminal"; then
        echo "[✔] Terminal already installed, skipping"
        return
    fi

    echo "[*] Setting up terminal..."

    gnome-terminal --geometry=192x26+0+0 &
    wget https://raw.githubusercontent.com/safesintesi/terminal-guillotine/main/guillotine.sh -qO- | bash

    finished "setup_terminal"
    echo "[✔] Success"
}

setup_extensions() {
    if executed "setup_extensions"; then
        echo "[✔] Extensions already installed, skipping"
        return
    fi

    echo "[*] Setting up extensions..."

    sudo apt install -y ubuntu-restricted-extras
    sudo apt install -y git meson
    sudo apt install -y libgtk-4-media-gstreamer
    sudo apt install -y gir1.2-gst-plugins-base-1.0 gir1.2-gst-plugins-bad-1.0

    wget https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v68.shell-extension.zip
    wget https://extensions.gnome.org/extension-data/compiz-alike-magic-lamp-effecthermes83.github.com.v21.shell-extension.zip
    wget https://github.com/hardpixel/unite-shell/releases/download/v82/unite-v82.zip
    wget https://extensions.gnome.org/extension-data/transparent-top-barftpix.com.v20.shell-extension.zip
    wget https://extensions.gnome.org/extension-data/hidetopbarmathieu.bidon.ca.v119.shell-extension.zip
    wget https://extensions.gnome.org/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v60.shell-extension.zip
    wget https://extensions.gnome.org/extension-data/search-lighticedman.github.com.v37.shell-extension.zip
    
    gnome-extensions install compiz-alike-magic-lamp-effecthermes83.github.com.v21.shell-extension.zip
    gnome-extensions install blur-my-shellaunetx.v68.shell-extension.zip
    gnome-extensions install unite-v82.zip
    gnome-extensions install transparent-top-barftpix.com.v20.shell-extension.zip
    gnome-extensions install hidetopbarmathieu.bidon.ca.v119.shell-extension.zip
    gnome-extensions install user-themegnome-shell-extensions.gcampax.github.com.v60.shell-extension.zip
    gnome-extensions install search-lighticedman.github.com.v37.shell-extension.zip

    git clone https://github.com/jeffshee/gnome-ext-hanabi.git -b gnome-47
    cd gnome-ext-hanabi
    ./run.sh install
    cd ..

    rm unite-v82.zip
    rm -rf gnome-ext-hanabi
    rm blur-my-shellaunetx.v68.shell-extension.zip
    rm transparent-top-barftpix.com.v20.shell-extension.zip
    rm hidetopbarmathieu.bidon.ca.v119.shell-extension.zip
    rm compiz-alike-magic-lamp-effecthermes83.github.com.v21.shell-extension.zip
    rm user-themegnome-shell-extensions.gcampax.github.com.v60.shell-extension.zip
    rm search-lighticedman.github.com.v37.shell-extension.zip

    finished "setup_extensions"
    echo "[✔] Success"
}

setup_ui() {
    if [ "$disable_ui" = false ]; then
        if executed "setup_ui"; then
            echo "[✔] UI already installed, skipping"
            return
        fi

        echo "[*] Setting up UI..."

        sudo apt install gnome-software -y
        sudo apt install gnome-shell-extension-manager -y
        sudo apt install x11-utils -y
        sudo apt install dconf-editor -y
        sudo apt install gnome-tweaks -y

        setup_theme
        setup_cursor
        setup_browser
        setup_insomnia
        setup_terminal
        setup_extensions

        install_flatpack
        install_apps

        wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Ubuntu/DConf/dconf-settings.ini"
        dconf load / < dconf-settings.ini
        rm dconf-settings.ini

        finished "setup_ui"
        echo "[✔] Success"
    else
        echo "[*] Skipping UI setup due to --noui flag"
    fi
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
install_docker

setup_ui

echo "[✔] Setup complete! Restart your computer for changes to take effect."
