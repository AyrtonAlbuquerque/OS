# -------------------------------------- Initial Setup -------------------------------------- #
    # Update everything first
    sudo apt update && sudo apt upgrade -y

    # Install build-essential
    sudo apt install build-essential

    # Install curl
    sudo apt install curl

    # Install Unzip
    sudo apt install unzip

    # Install gnupg ca-certificates
    sudo apt install gnupg ca-certificates

    # Install Software Properties Common
    sudo apt install software-properties-common
    
    # Install Gnome Software (24.04 or Higher)
    sudo apt install gnome-software

    # Install Gnome Shell Extension Manager
    sudo apt install gnome-shell-extension-manager

# ------------------------------------------- GIT ------------------------------------------- #
    # Install git
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get install git -y

    # Configure git (replace $USER and $EMAIL with your username and email)
    git config --global user.name "ayrton"
    git config --global user.email "ayrton_ito@hotmail.com"
    git config --global credential.helper cache
    
    # Install Git LFS
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install git-lfs
    git-lfs install

# ----------------------------------------- Terminal ---------------------------------------- #
    # Install a nerd font (Fira Code)
    wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip \
    && cd ~/.local/share/fonts \
    && unzip FiraCode.zip \
    && rm FiraCode.zip \
    && fc-cache -fv
    
    # Install ZSH
    sudo apt install zsh -y

    # Install Oh-My-Zsh and press Y and prompt. Log out and Log in again
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install Oh-My-Posh and its themes
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
    mkdir ~/.poshthemes
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.omp.*
    rm ~/.poshthemes/themes.zip

    # Install zsh autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

    # Open zshrc with nano
    sudo nano /etc/zsh/zshrc

    # Insert at the end then ctrl + O -> Enter -> ctrl + X
    eval "$(oh-my-posh init zsh --config /home/ayrton/.poshthemes/craver.omp.json)"
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

    # Apply the modification
    source /etc/zsh/zshrc

    # Set the geometry and initial position of the terminal
    gnome-terminal --geometry=192x26+0+0

    # There are 2 ways to hide the terminal title bar
    # The first and best way is to run the following command (https://github.com/safesintesi/terminal-guillotine)
    wget https://raw.githubusercontent.com/safesintesi/terminal-guillotine/main/guillotine.sh -qO- | bash

    # The other way is to run the following commands
    gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
    gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false

# -------------------------------------- NodeJs and NPM ------------------------------------- #
    # Install/Update NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
    source ~/.zshrc

    # Install Node (this will install the latest version as well as NPM latest version)
    nvm install node

    # To install the latest LTS version
    nvm install --lts

    # To install a specific version (14.17.6 for example)
    nvm install 14.17.6

    # To unistall a specific version (14.17.6 for example)
    nvm uninstall 14.17.6

    # To install the latest version of NPM
    nvm install-latest-npm

    # To see the installed versions directory
    nvm which current

    # To remove all versions except the current version
    find $HOME/.nvm/versions/node -mindepth 1 -maxdepth 1 -type d ! -name "$(node -v)" -exec rm -rf {} +

# ------------------------------------------ Python ----------------------------------------- #
    # Install deadsnakes/ppa
    sudo add-apt-repository ppa:deadsnakes/ppa

    # Refresh the cache
    sudo apt update

    # Install the desired version
    sudo apt install python3.13

    # Install pip
    sudo apt install python3-pip

    # Install python3 venv
    sudo apt install python3.13-venv

    # Create a symlink from the new version to python
    sudo ln -s /usr/bin/python3.13 /usr/bin/python

# ------------------------------------------- .NET ------------------------------------------ #
    # Download the dotnet-install.sh script
    wget https://dot.net/v1/dotnet-install.sh

    # Grant permissions to the script
    sudo chmod +x ./dotnet-install.sh

    # To install de latest LTS version
    ./dotnet-install.sh

    # To install the latest version
    ./dotnet-install.sh --version latest

    # To install the latest LTS verion of the Asp Net Core runtime
    ./dotnet-install.sh --runtime aspnetcore

    # To install the latest verion of the Asp Net Core runtime
    ./dotnet-install.sh --version latest --runtime aspnetcore

    # To install a specific version (7.0 for example)
    ./dotnet-install.sh --channel 7.0

    # Set PATH to the dotnet folder (replace $USER with your username)
    echo 'export PATH="$PATH:$HOME/.dotnet/"' >> ~/.zshrc
    echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.zshrc
    
    # Install Entity Framework
    dotnet tool install --global dotnet-ef
    
    # Set DOTNET_ROOT for Entity Framework
    echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.zshrc
    
    # Source it
    source ~/.zshrc

# ---------------------------------- Mono (.Net Framework) ---------------------------------- #
    # Add the package list to apt
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

    # Refresh the cache
    sudo apt update

    # Install Mono
    sudo apt install mono-devel

# ------------------------------------------- Java ------------------------------------------ #
    # Install the defualt version
    sudo apt install default-jre
    sudo apt install default-jdk

    # Its possible that the default version is not the latest. 
    # To install a specific version run the following command replacing $VERSION with the desired version
    sudo apt install openjdk-$VERSION-jdk

    # Or visit oracle downloads and download the latest debian package
    https://www.oracle.com/br/java/technologies/downloads/

    # You can have multiple Java installations on one server. 
    # You can configure which version is the default for use on the command line by using the update-alternatives command.
    sudo update-alternatives --config java

    # You can do this for other Java commands, such as the compiler (javac):
    sudo update-alternatives --config javac

    # To set JAVA_HOME append the following lines to the end of the ~/.zshrc file
    sudo nano ~/.zshrc

    # Get the $YOUR_JAVA_PATH using the command: sudo update-alternatives --config java.
    # For example /usr/lib/jvm/jdk-22-oracle-x64 (dont use the /bin/java at the end, just the version)
    JAVA_HOME=$YOUR_JAVA_PATH
    export PATH=$PATH:$JAVA_HOME/bin
    export JAVA_HOME

    # Source the file
    source ~/.zshrc

# ----------------------------------------- Texlive ----------------------------------------- #
    # Download the ISO file for the desired version (http://ftp.math.utah.edu/pub/tex/historic/systems/texlive)
    mkdir texlive
    cd texlive
    wget http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2021/texlive2021.iso

    # Mount the ISO file
    mkdir texlive
    sudo mount -o loop texlive2021.iso ./texlive
    cd texlive

    # Install texlive
    sudo ./install-tl

    # Unmount the ISO file
    cd ..
    sudo umount texlive2021.iso

    # Add texlive to the PATH
    echo 'export PATH="/usr/local/texlive/2021/bin/x86_64-linux:$PATH"' >> ~/.zshrc

    # Source the file
    source ~/.zshrc

    # Remove the texlive folder
    cd ..
    rm -rf texlive

    # Check the installation version
    latexmk --version

# ---------------------------------- GCC G++ GDB and CMAKE ---------------------------------- #
    # Install GCC and G++
    sudo apt install gcc g++
    
    # Install GDB
    sudo apt install gdb

    # Install CMake
    sudo apt install cmake

# ------------------------------------------ Docker ----------------------------------------- #
    # Unistall old versions
    sudo apt-get remove docker docker-engine docker.io containerd runc
    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    
    # Install packages to allow apt to use a repository over HTTPS
    sudo apt-get install ca-certificates curl gnupg

    # Add Docker’s official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up the stable repository
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the apt package index
    sudo apt-get update

    # Install Docker Engine
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Create the docker group
    sudo groupadd docker

    # Add your user to the docker group
    sudo usermod -aG docker $USER

    # Log out and log in again so that your group membership is re-evaluated

    # To start the Docker service
    sudo service docker start

    # To stop the Docker service
    sudo service docker stop

    # To list containers
    watch -n 1 docker ps

    # To view the logs of a container
    docker logs -f $CONTAINER_ID --tail $NUMBER_OF_LINES

    # To remove unused images
    docker image prune

    # To remove unused build cache
    docker builder prune

# ------------------------------------------ Neovim ----------------------------------------- #
    # Install pynvim
    pip install pynvim

    # Install latest version of Vim
    sudo add-apt-repository ppa:jonathonf/vim
    sudo apt update
    sudo apt install vim

    # Install Neovim (nightly version recommended)
    sudo add-apt-repository ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install neovim

    # Remove old config files
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim

    # Install ripgrep
    sudo apt install ripgrep

    # Install Tree-sitter CLI
    npm install tree-sitter-cli

    # Install AstroNVim
    git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim && nvim

    # Clone the template folder
    git clone https://github.com/AyrtonAlbuquerque/astronvim_template.git ~/.config/nvim/lua/user

    # Open ~/.config/nvim/lua/user with nvim and install the onedark theme inside plugins/user.lua
    "navarasu/onedark.nvim",
    {
        "navarasu/onedark.nvim",
        config = function()
            require('onedark').setup {
                colors = {
                    bg1 = "#282c34",
                    bg2 = "#282c34"
                },
            }
            require('onedark').load()
        end,
    },

    # Change the colorscheme inside init.lua
    colorscheme = "onedark"

    # Change the cursor to Beam add inside ~/.config/nvim init.lua
    vim.cmd([[ set guicursor= ]])

    # To install syntax hightlighting for a language (Lua for example)
    :TSInstall lua

    # To install language server for a language (Lua for example)
    :LspInstall lua

    # To install a dubber for a language (Lua for example)
    :DapInstall lua

    # To manage plugins
    :Lazy check # to check for plugin updates
    :Lazy update # to apply any pending plugin updates
    :Lazy clean # to remove any disabled or unused plugins
    :Lazy sync # to update and clean plugins

    # To update AstroNVim
    :AstroUpdate

    # To update AstroNVim packages
    :AstroUpdatePackages
# ------------------------------------ Remove Title Bars ------------------------------------ #
    # Install Unite extension
    sudo apt install x11-utils
    
    # Download the latest unite-shell.zip release and extrat it into ~/.local/share/gnome-shell/extensions
    https://github.com/hardpixel/unite-shell/releases

    # Open the extension configurations and set the following
    # On the General tab
    Show appmenu in top bar => Off
    Show desktop name in top bar => Off
    Restrict functionalities to the primary screen => Off
    Hide activities button => Always
    Hide window title bar => Maximized

    # Reboot the system

# ----------------------------------- Transparent Top Bar ----------------------------------- #
    # In Gnome Shell Extension Manager install the extension Transparent Top Bar (Adjustable transparency)

# --------------------------------------- Hide Top Bar -------------------------------------- #
    # In Gnome Shell Extension Manager install the extension Hide Top Bar

    # If on Ubuntu 24.04 and the extension still shows as unsupported do the following:
    # Open the extension folder at ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca
    # Open the metadata.json file and change the shell-version to the version of Gnome your distribution is using:
    "shell-version": ["45"] =>  "shell-version": ["46"]

    # Open the panelVisibilityManager.js file and change the following line:
    replace => display: global.display
    with => backend: global.backend

    # Reboot the system

# ----------------------------------- Transparent Taskbar ----------------------------------- #
    #  Install dconf-editor and open it
    sudo apt install dconf-editor

    # Go to org -> gnome -> shell -> extensions -> dash-to-dock 
    transparency-mode => FIXED

    # Go to org -> gnome -> shell -> extensions -> dash-to-dock 
    background-opacity => 0

    # Go to org -> gnome -> shell -> extensions -> dash-to-dock and toggle 
    show-apps-at-top => On

    # Go to org -> gnome -> shell -> extensions -> dash-to-dock and toggle 
    require-pressure-to-show => Off

    # Go to org -> gnome -> shell -> extensions -> dash-to-dock 
    show-delay => 0

    # Enable preview of windows when clicking on the icon
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'

# ------------------------------------------ Themes ----------------------------------------- #
    # Go to Gnome-Look.org and dowload a theme or get One Dark theme from seconds url
    https://www.gnome-look.org | https://github.com/UnnatShaneshwar/AtomOneDarkTheme

    # Extract the folder and show hidden files
    # Create a .themes folder and copy the extracted folder into it
    # Install Gnome-Tweaks and open it
    sudo apt install gnome-tweaks

    # In the Apperance tab set Legacy Applications to the One Dark theme

# ----------------------------------------- Cursors ----------------------------------------- #
    # Go to Gnome-Look.org and dowload a cursor 
    https://www.gnome-look.org/p/1356095

    # Extract the folder and place it inside the .icons folder in the home dir
    # In the Apperance tab set Cursor to the downloaded cursor

# ------------------------------------------ Icons ------------------------------------------ #
    # Go to Gnome-Look.org and dowload a icon pack 
    https://www.gnome-look.org/p/1166289

    # Extract the folder and place it inside the .icons folder in the home dir
    # In the Apperance tab set Icons to the downloaded icon pack

# ------------------------------------------ Fonts ------------------------------------------ #
    https://fonts.google.com/specimen/Fira+Code
    https://www.nerdfonts.com/font-downloads

# ------------------------------------- Usefull Commands ------------------------------------ #
    # To completely remove a package
    sudo apt-get purge --auto-remove $PACKAGE_NAME

    # To change python3 default version (Caution: This may break apt-pkg)
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

    # To revert python3 default version
    sudo update-alternatives --set python3 /usr/bin/python3.10
    
    # To remove an App installed using a .deb file. First find the package full name
    dpkg -l | grep -i $PACKAGE_NAME
    
    # Remove it
    sudo apt remove $PACKAGE_NAME
