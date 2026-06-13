#!/bin/bash
# ------------------------------------------------------------------------------------------- #
#                                     CachyOS Setup Script                                    #
# ------------------------------------------------------------------------------------------- #
set -e

# ---------------------------------------- Parameters --------------------------------------- #
git_user=""
git_email=""
dotnet="10"
disable_ui=false

for arg in "$@"; do
    case $arg in
        --git_user=*) git_user="${arg#*=}" ;;
        --git_email=*) git_email="${arg#*=}" ;;
        --dotnet=*) dotnet="${arg#*=}" ;;
        --noui) disable_ui=true ;;
        --help)
            echo "Usage: ./setup.sh [--git_user=...] [--git_email=...] [--dotnet=...] [--noui]"
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

    sudo pacman -Sy --noconfirm git || {
        echo "[!] Failed to install git."
    }

    if [[ -n "$git_user" ]]; then
        git config --global user.name "$git_user"
    fi

    if [[ -n "$git_email" ]]; then
        git config --global user.email "$git_email"
    fi

    echo "[*] Installing Git LFS..."

    sudo pacman -S --noconfirm git-lfs || {
        echo "[!] Failed to install Git LFS."
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

    sudo pacman -S --noconfirm ttf-firacode-nerd || {
        echo "[!] Failed to install Fira Code Nerd Font."
    }

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

    if ! pacman -Qi oh-my-posh &>/dev/null; then
        paru -S --noconfirm oh-my-posh-bin || {
            echo "[!] Failed to install Oh My Posh."
        }

        mkdir ~/.poshthemes
        wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
        unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
        chmod u+rw ~/.poshthemes/*.omp.*
        rm ~/.poshthemes/themes.zip
    fi

    if ! grep -q "oh-my-posh init zsh" ~/.zshrc; then
        sudo pacman -S --noconfirm zsh-autosuggestions zsh-syntax-highlighting
        echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/space.omp.json)"' >> ~/.zshrc
        echo 'source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
        echo 'source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
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
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    nvm install node
    npm install -g @microsoft/inshellisense
    is init zsh >> ~/.zshrc
    source ~/.zshrc

    finished "install_nvm"
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

    sudo pacman -S --noconfirm jdk-openjdk || {
        echo "[!] Failed to install JDK."
    }

    sudo archlinux-java set java-26-openjdk

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

    {
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
        sudo pacman -S --noconfirm docker docker-compose || {
            echo "[!] Failed to install Docker."
        }
        sudo systemctl enable --now docker
        sudo groupadd docker || true
        sudo usermod -aG docker "$USER"

        finished "install_docker"
        echo "[✔] Success"
    } || {
        echo "[!] Failed to install Docker. Most likely reason is that your distribution is not supported."
    }
}

install_apps() {
    if executed "install_apps"; then
        echo "[✔] Applications already installed, skipping"
        return
    fi

    echo "[*] Installing Applications..."

    # vscode
    paru -S visual-studio-code-bin || {
        echo "[!] Failed to install Visual Studio Code."
    }

    # stremio service
    flatpak install flathub com.stremio.Service -y

    # jetbrains toolbox
    sudo pacman -S --noconfirm libxi libxrender libxtst mesa fontconfig gtk3 || {
        echo "[!] Failed to install JetBrains Toolbox dependencies."
    }

    {
        echo "[*] Installing JetBrains Toolbox..."
        curl -fsSL https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Utilities/Toolbox/toolbox-install.sh | bash &&
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

    sudo pacman -S --noconfirm flatpak || {
        echo "[!] Failed to install Flatpak."
    }

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

    mkdir -p "$HOME/Zen"

    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/CachyOS/Browser/firefox.png" -O "$HOME/Pictures/firefox.png"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/Configuration/AdBlocker.txt" -O "$HOME/Zen/AdBlocker.txt"
    wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/Configuration/Enhancer%20for%20Youtube.json" -O "$HOME/Zen/Enhancer for Youtube.json"
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

            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/userChrome.css" -O "$chrome_folder/userChrome.css"
            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/user.js" -O "$default_profile/user.js"
            wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/sine-mods.zip" -O "$HOME/Zen/sine-mods.zip"

            unzip "$HOME/Zen/sine-mods.zip" -d "$chrome_folder"
        else
            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/userChrome.css" -O "$HOME/Zen/userChrome.css"
            wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/user.js" -O "$HOME/Zen/user.js"
            wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/sine-mods.zip" -O "$HOME/Zen/sine-mods.zip"
        fi
    else
        wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/userChrome.css" -O "$HOME/Zen/userChrome.css"
        wget "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/user.js" -O "$HOME/Zen/user.js"
        wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Browser/sine-mods.zip" -O "$HOME/Zen/sine-mods.zip"
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

    mkdir -p "$HOME/Applications"
    wget "https://github.com/Kong/insomnia/releases/download/core%402022.6.0/Insomnia.Core-2022.6.0.AppImage" -O "$HOME/Applications/Insomnia.AppImage"
    chmod +x "$HOME/Applications/Insomnia.AppImage"
    sudo ln -sf "$HOME/Applications/Insomnia.AppImage" /usr/local/bin/insomnia
    mkdir -p "$HOME/.config/Insomnia"

    if [ ! -d "$HOME/.local/share/applications" ]; then
        mkdir -p "$HOME/.local/share/applications"
    fi

    mkdir -p "$HOME/.config/Insomnia/plugins/insomnia-plugin-save-variables"
    wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/CachyOS/Utilities/Insomnia/insomnia-plugin-one-dark-theme.zip"
    unzip insomnia-plugin-one-dark-theme.zip -d "$HOME/.config/Insomnia/plugins"
    rm insomnia-plugin-one-dark-theme.zip
    git clone "https://github.com/fabiosousapro/insomnia-plugin-query-parameter-tag.git" "$HOME/.config/Insomnia/plugins/insomnia-plugin-query-parameter-tag"

    cat <<-EOF > ~/.local/share/applications/insomnia.desktop
        [Desktop Entry]
        Exec=$HOME/Applications/Insomnia.AppImage
        Icon=$HOME/.config/Insomnia/icon.png
        Name[en_US]=Insomnia
        Name=Insomnia
        StartupNotify=true
        Terminal=false
        Type=Application
        Categories=Development;
        X-KDE-SubstituteUID=false
	EOF

    finished "setup_insomnia"
    echo "[✔] Success"
}

setup_launcher() {
    if executed "setup_launcher"; then
        echo "[✔] Launcher already installed, skipping"
        return
    fi

    echo "[*] Setting up launcher..."

    paru -S --noconfirm ulauncher || {
        echo "[!] Failed to install Ulauncher."
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
        sudo pacman -S --noconfirm \
            extra-cmake-modules \
            plasma-workspace \
            libdrm \
            kservice \
            kwin \
            kconfigwidgets \
            knotifications \
            kio \
            kbookmarks \
            layer-shell-qt || {
            echo "[!] Failed to install dependencies."
        }

        paru -S --noconfirm plasma5-applets-active-window-control 2>/dev/null || true

        if [ ! -d "$HOME/.local/share/applications" ]; then
            mkdir -p "$HOME/.local/share/applications"
        fi

        wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/CachyOS/Programs/applications.desktop" -O "$HOME/.local/share/applications/applications.desktop"
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
        # dependencies
        sudo pacman -S --noconfirm \
            xorg-xdpyinfo \
            xdotool \
            yakuake \
            cmake \
            gcc \
            extra-cmake-modules \
            qt6-tools \
            kwin \
            kconfigwidgets \
            gettext \
            kcrash \
            kglobalaccel \
            kio \
            kservice \
            knotifications \
            kcmutils \
            kdecoration \
            xcb-util \
            libxcb \
            plasma-workspace \
            libdrm \
            kvantum \
            kvantum-qt5 || {
            echo "[!] Failed to install dependencies."
        }

        # kwin-effects-glass
        git clone https://github.com/4v3ngR/kwin-effects-glass

        {
            (
                cd kwin-effects-glass
                mkdir build && cd build
                cmake .. -DCMAKE_INSTALL_PREFIX=/usr
                make -j$(nproc)
                sudo make install
            )
        } || {
            echo "[!] Failed to set up kwin-effects-glass"
        }

        # BreezeEnhanced
        git clone https://github.com/tsujan/BreezeEnhanced.git

        {
            (
                cd BreezeEnhanced
                mkdir build && cd build
                cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
                make
                sudo make install
            )
        } || {
            echo "[!] Failed to set up Breeze Enhanced"
        }
        
        echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/20_lofree_fn_mode_fix.conf
        echo "snap" >> .hidden
        echo "org.vicko.wavetask" >> .hidden
        echo "kwin-effects-glass" >> .hidden
        echo "BreezeEnhanced" >> .hidden
        echo "Music" >> .hidden
        echo "Templates" >> .hidden
        
        install_flatpak
        setup_browser
        setup_insomnia
        setup_launcher
        setup_dock
        install_apps

        wget "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/CachyOS/Wallpaper/Wallpaper.mp4" -O "$HOME/Videos/Wallpaper.mp4"
        wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Wallpaper/Wallpapper.png?download=true" -O "$HOME/Pictures/Wallpaper.png"
        wget "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/CachyOS/Konsave/cachyos.knsv" -O "$HOME/cachyos.knsv"

        {
            konsave -i cachyos.knsv
            konsave -a cachyos
            rm cachyos.knsv
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

sudo pacman -Syu --noconfirm

install_git
install_zsh
install_nvm
install_dotnet
install_java
install_docker

setup_ui

echo "[✔] Setup complete! Restart your computer for changes to take effect."
