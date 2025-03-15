# -------------------------------------- Initial Setup -------------------------------------- #
    # Install Windows Terminal with winget
    winget install Microsoft.WindowsTerminal
    
    # In a terminal as Administrator
    irm christitus.com/win | iex

    # Install Fira Code Nerd Font
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip

    # One Dark Theme
    # Downlaod and install UltraUXThemePatcher
    https://mhoefs.eu/software_uxtheme.php?ref=syssel&lang=en

    # Install the One Dark Theme by placing the files at:
    C:\Windows\Resources\Themes

    # Restart the computer

    # Install the StartAllBack
    winget install StartIsBack.StartAllBack

    # Configure StartAllBack as follows:
    # In Taskbar tab
    Taskbar location on screen: Bottom
    Combine taskbar buttons: Always, hide labels
    On secondary taskbars: Always, hide labels
    Centered taskbar icons: Together with the Start button

    # In Explorer tab
    Win7 Command Bar
    Classic search box: checked
    New icons: checked
    Classic context menus: unchecked
    Restore Control Panel applets: checked

# ------------------------------------------- Git ------------------------------------------- #
    # Install Git
    winget install Git.Git

    # Configure Git
    git config --global user.name "ayrton"
    git config --global user.email "ayrton_ito@hotmail.com"

# ---------------------------------------- Powershell --------------------------------------- #
    # Install PowerShell with winget (Make sure to check the PATH)
    winget install Microsoft.PowerShell

    # Open a CMD as Administrator, run the following command and close
    pwsh.exe -noprofile -command "Install-Module PSReadLine -Force -AllowPrerelease -SkipPublisherCheck"

    # In PowerShell (As Administrador)
    # Install oh-my-posh
    Install-Module oh-my-posh

    # Install posh-git
    Install-Module posh-git

    # Install PSReadLine for autocomplete inside powershell
    Install-Module PSReadLine -Force

    # Install the theme
    winget install JanDeDobbeleer.OhMyPosh

    # Open the profile file
    notepad $PROFILE

    # Append the following lines in the opened file
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\craver.omp.json" | Invoke-Expression
    Import-Module posh-git
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView

# ------------------------------------------- WSL2 ------------------------------------------ #
    # Install WSL2 (PowerShell as Administrador)
    wsl --install

    # If the above command fails (Older versions of Windows)

    # Enable the Windows Subsystem for Linux
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

    # Enable Windows Virutal Machine Platform
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    # Download and install the Linux Kernel Update Package
    https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

    # Set WSL2 as default version
    wsl --set-default-version 2

    # Install a Linux Distribution
    wsl --install -d $DISTRO_NAME

    # Restart the computer

    # To list all the available distributions (replace $DISTRO_NAME)
    wsl --list --online

    # To update a distribution version (replace $DISTRO_NAME)
    wsl --set-version $DISTRO_NAME 2

    # To list all the installed distributions
    wsl --list --verbose

    # To shutdown wsl
    wsl --shutdown

    # To unregister a distribution (replace $DISTRO_NAME)
    wsl --unregister $DISTRO_NAME

# ------------------------------------------ MinGW ------------------------------------------ #
    # Download the latest version
    https://github.com/niXman/mingw-builds-binaries/releases

    # Extract it into C:\Program Files
    # Add the path to the environment variables
    C:\Program Files\mingw64\bin

# ------------------------------------------ CMake ------------------------------------------ #
    # Download the latest version
    winget upgrade Kitware.CMake

    # Add the path to the environment variables
    C:\Program Files\CMake\bin

# ---------------------------------------- Node & NPM --------------------------------------- #
    # Install/Update NVM
    winget install CoreyButler.NVMforWindows

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

    # To remove all versions except the current version, go to the folder in the command
    nvm root

# ------------------------------------------ Python ----------------------------------------- #
    # Install Python (3.12 for example)
    winget install Python.Python.3.12

# ------------------------------------------- Java ------------------------------------------ #
    # Install Java (22 for example)
    winget install Oracle.JDK.22

# ---------------------------------------- .NET Core ---------------------------------------- #
    # Install the SDK (8 for example)
    winget install Microsoft.DotNet.SDK.8

    # Install Entity Framework
    dotnet tool install --global dotnet-ef

    # To install/update the Entity Framework to a specific version (7.0.15 for example)
    dotnet tool update --global dotnet-ef --version 7.0.15

# -------------------------------------- .NET Framework ------------------------------------- #``
    # Download the latest version
    https://dotnet.microsoft.com/en-us/download/dotnet-framework

    # To be able to debug .NET Framework applications in Visual Studio Code, install the build tools
    winget install Microsoft.VisualStudio.2019.BuildTools

    # In the Visual Studio Installer, select the Web Development Build Tools and check everything that is not out of support 

# -------------------------------------- Docker Desktop ------------------------------------- #
    # Requires WSL2
    # To install the Docker Desktop
    winget install Docker.DockerDesktop

    # To start the Docker Desktop
    Start-Process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# -------------------------------------- Docker Engine -------------------------------------- #
    # To install the Docker CLI
    winget install Docker.DockerCLI

    # To install the Docker Compose
    winget install Docker.DockerCompose

    # Create the DOCKER_HOST environment variable
    setx DOCKER_HOST tcp://localhost:2375

    # Register the Docker service (As Administrator)
    dockerd --register-service

    # To start the Docker service
    net start docker

    # To stop the Docker service
    net stop docker

    # Useful Docker commands

    # To Delete all containers
    docker rm $(docker ps -a -q)

    # To Delete all images
    docker rmi $(docker images -q)

    # To Delete a Network
    docker network rm $NETWORK_NAME

    # To Stop all containers
    docker stop $(docker ps -q)

    # To see the logs of a container
    docker logs -f $CONTAINER_ID --tail $NUMBER_OF_LINES

    # To create a network on Linux and WSL2
    docker network create -d bridge $NETWORK_NAME

    # To create a network on Windows
    docker network create -d nat $NETWORK_NAME

    # To run a container with complex options
    docker run --name $CONTAINER_NAME -p $HOST_PORT:$CONTAINER_PORT --network $NETWORK_NAME \
    -e $ENVIRONMENT_VARIABLE=$VALUE \
    -e $ENVIRONMENT_VARIABLE=$VALUE \
    -e $ENVIRONMENT_VARIABLE=$VALUE \
    -e $ENVIRONMENT_VARIABLE=$VALUE \
    -d $IMAGE_NAME:$TAG

# ----------------------------------- Virtual Box - Docker ---------------------------------- #
    # To enable Virtualization, execute and reboot
    bcdedit /set hypervisorlaunchtype off
    DISM /Online /Disable-Feature:Microsoft-Hyper-V

    # To enable Docker, execute and reboot
    bcdedit /set hypervisorlaunchtype auto
    DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V

# ------------------------------------------ Neovim ----------------------------------------- #
    # Install latest version of Vim
    https://www.vim.org/download.php

    # Add the vim folder to PATH (version 9.0 for example)
    C:\Program Files (x86)\Vim\vim90

    # Install Neovim (nightly version recommended)
    https://github.com/neovim/neovim/releases/tag/nightly

    # Add the neovim folder to PATH
    C:\Program Files\Neovim\bin

    # Remove old config files
    rd -r ~\AppData\Local\nvim
    rd -r ~\AppData\Local\nvim-data

    # Install ripgrep (as admin in terminal)
    choco install ripgrep

    # Install Tree-sitter CLI
    npm install tree-sitter-cli

    # Install AstroNVim
    git clone --depth 1 https://github.com/AstroNvim/AstroNvim $HOME\AppData\Local\nvim && nvim

    # Clone the template folder
    git clone https://github.com/AyrtonAlbuquerque/astronvim_template.git $HOME\AppData\Local\nvim\lua\user

    # Open $HOME\AppData\Local\nvim\lua\user with nvim and install the onedark theme inside plugins\user.lua
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

# ------------------------------------------------------------------------------------------- #
#                                             WSL2                                            #
# ------------------------------------------------------------------------------------------- #
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

# ----------------------------------------- Terminal ---------------------------------------- #    
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
    chmod u+rw ~/.poshthemes/*.json
    rm ~/.poshthemes/themes.zip

    # Install zsh autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

    # Open zshrc with nano
    nano ~/.zshrc

    # Insert at the end then ctrl + O -> Enter -> ctrl + X
    eval "$(oh-my-posh --init --shell zsh --config '~/.poshthemes/craver.omp.json')"
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

    # Apply the modification
    source ~/.zshrc

# -------------------------------------- NodeJs and NPM ------------------------------------- #
    # Install/Update NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

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

# ------------------------------------------ Python ----------------------------------------- #
    # Install deadsnakes/ppa
    sudo add-apt-repository ppa:deadsnakes/ppa

    # Refresh the cache
    sudo apt update

    # Install the desired version
    sudo apt install python3.11

    # Install pip
    sudo apt install python3-pip

    # Create a symlink from the new version to python
    sudo ln -s /usr/bin/python3.11 /usr/bin/python

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
    echo 'export PATH="$PATH:/home/$USER/.dotnet/"' >> ~/.zshrc

# ---------------------------------- Mono (.Net Framework) ---------------------------------- #
    # Add the package list to apt
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

    # Refresh the cache
    sudo apt update

    # Install Mono
    sudo apt install mono-devel

# ---------------------------------- GCC G++ GDB and CMAKE ---------------------------------- #
    # Install GCC and G++
    sudo apt install gcc g++
    
    # Install GDB
    sudo apt install gdb

    # Install CMake
    sudo apt install cmake

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

