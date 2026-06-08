#!/bin/bash
# ------------------------------------------------------------------------------------------- #
#                                     Kubuntu Setup Script                                    #
# ------------------------------------------------------------------------------------------- #
set -e

# ---------------------------------------- Parameters --------------------------------------- #
git_user=""
git_email=""
git_credencial=""
python="3.14"
dotnet="10"
java="26"
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

trap 'echo "[!] State saved in $MARKERS"' ERR
trap cleanup EXIT

# ---------------------------------------- Functions ---------------------------------------- #
install_git() {
    if executed "install_git"; then
        echo "[✔] Git already installed, skipping"
        return
    fi

    echo "[*] Installing Git..."

    {
        sudo add-apt-repository -y ppa:git-core/ppa
        sudo apt update &&
    } || {
        echo "[!] Failed to install git. Most likely reason is that your distribution is not supported by the PPA."
        sudo add-apt-repository --remove ppa:git-core/ppa -y
        sudo apt update
    }

    sudo apt install git -y

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

    {
        curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
        sudo apt install git-lfs -y
        git-lfs install
        sudo apt update
    } || {
        echo "[!] Failed to install Git LFS. Most likely reason is that your distribution is not supported by the Git LFS installation script."
        sudo rm /etc/apt/sources.list.d/github_git-lfs.list
        sudo apt update
    }

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
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

        echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/space.omp.json)"' >> ~/.zshrc
        echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
        echo 'source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
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
    nvm install node
    npm install -g @microsoft/inshellisense
    is init zsh >> ~/.zshrc
    source ~/.zshrc

    finished "install_nvm"
    echo "[✔] Success"
}

install_python() {
    {
        if executed "install_python"; then
            echo "[✔] Python already installed, skipping"
            return
        fi

        echo "[*] Installing Python..."

        {
            sudo add-apt-repository ppa:deadsnakes/ppa -y
            sudo apt update &&
        } || {
            echo "[!] Failed to install Python. Most likely reason is that your distribution is not supported by the deadsnakes PPA."
            sudo add-apt-repository --remove ppa:deadsnakes/ppa -y
            sudo apt update
        }

        if [[ -n "$python" ]]; then
            sudo apt install python"$python" -y
            sudo apt install python3-pip -y
            sudo apt install python"$python"-venv -y
            sudo ln -s /usr/bin/python"$python" /usr/bin/python
        else
            sudo apt install python3.14 -y
            sudo apt install python3-pip -y
            sudo apt install python3.14-venv -y
            sudo ln -s /usr/bin/python3.14 /usr/bin/python
        fi

        finished "install_python"
        echo "[✔] Success"
    } || {
        echo "[!] Failed to install Python. Most likely reason is that your distribution is not supported by the deadsnakes PPA."
    }
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
        ./.dotnet-install.sh --channel 10.0
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
        wget https://download.oracle.com/java/26/latest/jdk-26_linux-x64_bin.deb
        sudo dpkg -i jdk-26_linux-x64_bin.deb
        rm jdk-26_linux-x64_bin.deb
    fi

    JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which javac))))
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.zshrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.zshrc
    source ~/.zshrc

    finished "install_java"
    echo "[✔] Success"
}

install_docker() {
    {
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
    } || {
        echo "[!] Failed to install Docker. Most likely reason is that your distribution is not supported by the Docker installation script yet."
    }
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

    { 
        sudo apt update
        sudo apt install code -y
    } || { 
        echo "[!] Failed to install Visual Studio Code. Most likely reason is that your distribution is not supported by the Visual Studio Code repository yet." 
    }

    # stremio service
    flatpak install flathub com.stremio.Service -y

    # jetbrains toolbox
    sudo apt install -y libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin
    {
        echo "[*] Installing JetBrains Toolbox..."
        curl -fsSL https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Utilities/Toolbox/toolbox-install.sh | bash &&
    } || {
        echo "[!] Failed to install JetBrains Toolbox"
    }

    # Flatseal
    flatpak install flathub com.github.tchx84.Flatseal -y

    finished "install_apps"
    echo "[✔] Success"
}

install_flatpak() {
    if executed "install_flatpak"; then
        echo "[✔] Flatpak already installed, skipping"
        return
    fi

    echo "[*] Installing Flatpak..."

    sudo apt install flatpak -y
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    finished "install_flatpak"
    echo "[✔] Success"
}

setup_browser() {
    if executed "setup_browser"; then
        echo "[✔] Browser already installed, skipping"
        return
    fi

    echo "[*] Setting up browser..."

    {
        sudo add-apt-repository universe
        sudo apt update
    } || {
        echo "[!] Failed to set up browser. Most likely reason is that your distribution is not supported by universe package yet."
        sudo add-apt-repository --remove universe -y
        sudo apt update
    }

    {
        sudo apt install -y libfuse2
    } || {
        echo "[!] Failed to install libfuse2"
    }

    {
        sudo apt install -y libfuse2t64
    } || {
        echo "[!] Failed to install libfuse2t64"
    }

    mkdir -p "$HOME/Zen"
    # mkdir -p "$HOME/Applications"
    # mkdir -p "$HOME/Applications/zen"

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Kubuntu/Browser/firefox.png" -O "$HOME/Pictures/firefox.png"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/Configuration/AdBlocker.txt" -O "$HOME/Zen/AdBlocker.txt"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/Configuration/Enhancer%20for%20Youtube.json" -O "$HOME/Zen/Enhancer for Youtube.json"
    wget "https://github.com/CosmoCreeper/Sine/releases/download/v2.3/sine-flatpak.sh"

    chmod +x ./sine-flatpak.sh

    flatpak install flathub app.zen_browser.zen -y

    flatpak run app.zen_browser.zen &
    zen_pid=$!
    sleep 5
    pkill -f "app.zen_browser.zen" 2>/dev/null || true

    profiles_dir="$HOME/.var/app/app.zen_browser.zen/.zen"

    if [[ -d "$profiles_dir" ]]; then
        default_profile=$(find "$profiles_dir" -type d -name "*.Default (release)" | head -1)
        
        if [[ -n "$default_profile" ]]; then
            chrome_folder="$default_profile/chrome"
            
            if [[ ! -d "$chrome_folder" ]]; then
                mkdir -p "$chrome_folder"
            fi

            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/userChrome.css" -O "$chrome_folder/userChrome.css"
            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/user.js" -O "$default_profile/user.js"
            wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/sine-mods.zip" -O "$HOME/Zen/sine-mods.zip"

            unzip "$HOME/Zen/sine-mods.zip" -d "$chrome_folder"
        else
            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/userChrome.css" -O "$HOME/Zen/userChrome.css"
            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/user.js" -O "$HOME/Zen/user.js"
            wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/sine-mods.zip" -O "$HOME/Zen/sine-mods.zip"
        fi
    else
        wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/userChrome.css" -O "$HOME/Zen/userChrome.css"
        wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/user.js" -O "$HOME/Zen/user.js"
        wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Browser/sine-mods.zip" -O "$HOME/Zen/sine-mods.zip"
    fi

    ./sine-flatpak.sh -y
    rm sine-flatpak.sh

    finished "setup_browser"
    echo "[✔] Success"
}

setup_insomnia() {
    if executed "setup_insomnia"; then
        echo "[✔] Insomnia already installed, skipping"
        return
    fi

    echo "[*] Setting up Insomnia..."

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Kubuntu/Programs/Insomnia.deb"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Utilities/Insomnia/Insomnia"

    sudo dpkg -i Insomnia.deb
    rm Insomnia.deb

    mkdir -p "$HOME/.config/Insomnia/plugins/insomnia-plugin-save-variables"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Kubuntu/Utilities/Insomnia/insomnia-plugin-one-dark-theme.zip"
    unzip insomnia-plugin-one-dark-theme.zip -d "$HOME/.config/Insomnia/plugins"
    rm insomnia-plugin-one-dark-theme.zip
    git clone "https://github.com/fabiosousapro/insomnia-plugin-query-parameter-tag.git" "$HOME/.config/Insomnia/plugins/insomnia-plugin-query-parameter-tag"

    finished "setup_insomnia"
    echo "[✔] Success"
}

setup_launcher() {
    if executed "setup_launcher"; then
        echo "[✔] Launcher already installed, skipping"
        return
    fi

    echo "[*] Setting up launcher..."

    sudo apt install gir1.2-gtklayershell-0.1 -y

    { 
        sudo add-apt-repository universe -y && sudo add-apt-repository ppa:agornostal/ulauncher -y && sudo apt update && sudo apt install ulauncher -y 
    } || { 
        echo "[!] Failed to install Ulauncher. Most likely reason is that your distribution is not supported by the Ulauncher PPA yet."
        sudo add-apt-repository --remove universe -y
        sudo add-apt-repository --remove ppa:agornostal/ulauncher -y
        sudo apt update
    }

    if [ ! -d "$HOME/.config/ulauncher" ]; then
        mkdir -p "$HOME/.config/ulauncher"
    fi

    git clone https://github.com/kayozxo/ulauncher-liquid-glass.git

    {
        (
            cd ulauncher-liquid-glass
            ./install.sh
        )
    } || {
        echo "[!] Failed to set up Ulauncher theme."
    }

    rm -rf ulauncher-liquid-glass

    finished "setup_launcher"
    echo "[✔] Success"
}

setup_dock() {
    if executed "setup_dock"; then
        echo "[✔] Dock already installed, skipping"
        return
    fi

    echo "[*] Setting up dock..."

    {
        sudo apt install -y libplasma-dev libplasmaactivities-dev libplasmaactivitiesstats-dev libdrm-dev plasma-workspace-dev libksysguard-dev libkf6service-dev kwin-dev libkf6configwidgets-dev libkf6notifications-dev libkf6kio-dev libkf6bookmarks-dev

        if [ ! -d "$HOME/.local/share/applications" ]; then
            mkdir -p "$HOME/.local/share/applications"
        fi

        wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Kubuntu/Programs/applications.desktop" -O "$HOME/.local/share/applications/applications.desktop"
        chmod +x "$HOME/.local/share/applications/applications.desktop"
        git clone https://github.com/vickoc911/org.vicko.wavetask.git

        (
            cd org.vicko.wavetask
            mkdir build && cd build
            cmake .. -DCMAKE_BUILD_TYPE=Release
            make -j$(nproc)
            sudo make install
        )

        echo "[✔] Success"
    } || {
        echo "[!] Failed to set up dock."
    }

    finished "setup_dock"
}

setup_ui() {
    if [ "$disable_ui" = false ]; then
        if executed "setup_ui"; then
            echo "[✔] UI already installed, skipping"
            return
        fi

        echo "[*] Setting up UI..."

        sudo apt install x11-utils -y
        sudo apt install xdotool -y
        sudo apt install yakuake -y
        sudo apt install pipx -y

        {
            sudo add-apt-repository ppa:papirus/papirus
            sudo apt update
            sudo apt install -y qt6-style-kvantum qt6-style-kvantum-themes
        } || {
            echo "[!] Failed to install Kvantum. Most likely reason is that your distribution is not supported by the PPA."
            sudo add-apt-repository --remove ppa:papirus/papirus -y
            sudo apt update
        }

        echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/20_lofree_fn_mode_fix.conf
        echo "snap" >> .hidden
        echo "org.vicko.wavetask" >> .hidden
        echo "Templates" >> .hidden

        install_flatpak
        setup_browser
        setup_insomnia
        setup_launcher
        setup_dock
        install_apps

        pipx ensurepath
        pipx install konsave
        source ~/.zshrc

        wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Kubuntu/Wallpaper/Wallpaper.mp4" -O "$HOME/Videos/Wallpaper.mp4"
        wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Kubuntu/Invisible.png" -O "$HOME/Pictures/Invisible.png"
        wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Wallpaper/Wallpapper.png?download=true" -O "$HOME/Pictures/Wallpaper.png"
        wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/Kubuntu/Konsave/kubuntu26.knsv" -O "$HOME/kubuntu26.knsv"

        {
            konsave -i kubuntu26.knsv
            konsave -a kubuntu26
            # rm kubuntu26.knsv
        } || {
            echo "[!] Failed to import Konsave configuration."
        }

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
