# ------------------------------------------------------------------------------------------- #
#                                     Windows Setup Script                                    #
# ------------------------------------------------------------------------------------------- #

# ---------------------------------------- Parameters ---------------------------------------- #
param (
    [string]$GitUser = "ayrton",
    [string]$GitEmail = "ayrton_ito@hotmail.com",
    [string]$Java = "23",
    [string]$Python = "3.13",
    [string]$DotNet = "9",
    [string]$Distribution = "Ubuntu-24.04"
)

# ---------------------------------------- Functions ---------------------------------------- #
function OSVersion() {
    $version = [System.Environment]::OSVersion.Version

    if ($version.Major -eq 10 -and $version.Build -lt 22000) {
        return 10
    }

    return 11
}

function Install($package) {
    Write-Host "---------------------- Installing $package ----------------------"

    try {
        Start-Process "winget" -ArgumentList @("install", $package) -Wait
        Write-Host "✔ Success"
    }
    catch {
        Write-Warning "✖ Failed: $_"
    }
}

function Execute([scriptblock] $action) {
    Write-Host "---------------------- Executing $action ----------------------"

    try {
        & $action
        Write-Host "✔ Success"
    }
    catch {
        Write-Warning "✖ Failed: $_"
    }
}

function SetupGit($name, $email) {
    Install "Git.Git"
    Execute { git config --global user.name $name }
    Execute { git config --global user.email $email }
}

function SetupPowerShell() {
    $configuration = @(
        'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\craver.omp.json" | Invoke-Expression',
        'Import-Module posh-git',
        'Set-PSReadLineOption -PredictionSource History',
        'Set-PSReadLineOption -PredictionViewStyle ListView'
    )

    Install "Microsoft.PowerShell"
    Install "JanDeDobbeleer.OhMyPosh"
    Execute { pwsh.exe -noprofile -command "Install-Module PSReadLine -Force -AllowPrerelease -SkipPublisherCheck" }
    Execute { pwsh.exe -noprofile -command "Install-Module oh-my-posh -Force" }
    Execute { pwsh.exe -noprofile -command "Install-Module posh-git -Force" }
    Execute { pwsh.exe -noprofile -command "Install-Module PSReadLine -Force" }

    try {
        if (!(Test-Path $PROFILE)) { 
            New-Item -ItemType File -Path $PROFILE -Force | Out-Null 
            Add-Content -Path $PROFILE -Value $configuration
        }
    }
    catch {
        Write-Warning "✖ Failed Powershell installation: $_"
    }
}

function SetupWSL($distribution) {
    Write-Host "---------------------- Installing WSL2 ----------------------"
    
    try {
        if ((OSVersion) -eq 10) {
            $installer = "$env:TEMP\wsl_update_x64.msi"

            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
            Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile $installer
            Start-Process msiexec.exe -ArgumentList "/i `"$installer`" /quiet /norestart" -Wait
            Write-Host "✔ Success. After rebooting, install a distribution: wsl --install -d Ubuntu-24.04"
        }
        else {
            wsl --install -d $distribution
        }
    }
    catch {
        Write-Warning "✖ Failed WSL2 installation: $_"
    }
}

function SetupStartAllBack($url) {
    try {
        if ((OSVersion) -eq 11) {
            $file = "$env:TEMP\start-is-back.reg"

            Install "StartIsBack.StartAllBack"
            Invoke-WebRequest -Uri $url -OutFile $file
            reg import $file
        }
        else {
            Install "StartIsBack.StartIsBack"
        }
    }
    catch {
        Write-Warning "✖ Failed StartAllBack installation: $_"
    }
}

function SetupWindHawk($url) {
    try {
        $root = "C:\ProgramData\Windhawk"
        $file = "$env:TEMP\windhawk-backup.zip"
        $folder = Join-Path $env:TEMP "WindhawkRestore"
    
        Install "RamenSoftware.Windhawk"
        Invoke-WebRequest -Uri $url -OutFile $file
        Expand-Archive -Path $file -DestinationPath $folder -Force
        Copy-Item "$folder\ModsSource" -Destination $root -Recurse -Force
    
        if (!(Test-Path "$root\Engine")) { 
            New-Item -ItemType Directory -Path "$root\Engine" -Force | Out-Null 
        }
        
        Copy-Item "$folder\Engine\Mods" -Destination "$root\Engine" -Recurse -Force
    
        if (Test-Path "$folder\Windhawk.reg") { 
            reg import "$folder\Windhawk.reg" 
        }
    }
    catch {
        Write-Warning "✖ Failed WindHawk installation: $_"
    }
}

function SetupFont($url) {
    Write-Host "---------------------- Installing Font ----------------------"

    try {
        $file = "$env:TEMP\FiraCode.zip"
        $folder = "$env:TEMP\FiraCodeFonts"

        Invoke-WebRequest -Uri $url -OutFile $file
        Expand-Archive -Path $file -DestinationPath $folder -Force

        $fonts = Get-ChildItem -Path $folder -Recurse -Include *.ttf, *.otf

        foreach ($font in $fonts) {
            Copy-Item $font.FullName -Destination "$env:WINDIR\Fonts" -Force
            $name = [System.IO.Path]::GetFileNameWithoutExtension($font.Name)
            $type = if ($font.Extension -eq ".ttf") { " (TrueType)" } elseif ($font.Extension -eq ".otf") { " (OpenType)" } else { "" }
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$name$type" -Value $font.Name -PropertyType String -Force | Out-Null
        }
    }
    catch {
        Write-Warning "✖ Failed Font installation: $_"
    }
}

function SetupUnite($url) {
    Write-Host "---------------------- Installing Unite ----------------------"

    try {
        $folder = [Environment]::GetFolderPath("Startup")
        $target = Join-Path $folder "Unite.exe"

        if (!(Test-Path $target)) {
            Invoke-WebRequest -Uri $url -OutFile $target
        }
        else {
            Write-Host "Unite already installed."
        }
    }
    catch {
        Write-Warning "✖ Failed Unite installation: $_"
    }
}

function SetupTheme($url) {
    Write-Host "---------------------- Installing Theme ----------------------"

    try {
        $patcher = "$env:TEMP\ThemePatcher.exe"
        $theme = "$env:TEMP\OneDark.zip"

        Invoke-WebRequest -Uri $url -OutFile $theme
        Expand-Archive -Path $theme -DestinationPath "$env:WINDIR\Resources\Themes" -Force
        Invoke-WebRequest -Uri "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/Theme%20Patcher.exe" -OutFile $patcher
        Start-Process -FilePath $patcher -Wait
    }
    catch {
        Write-Warning "✖ Failed Theme installation: $_"
    }
}

# ---------------------------------------- Execution ---------------------------------------- #
Install "Oracle.JDK.$Java"
Install "Python.Python.$Python"
Install "Microsoft.DotNet.SDK.$DotNet"
Install "Kitware.CMake"
Install "Docker.DockerDesktop"
Install "CoreyButler.NVMforWindows"
Install "BrechtSanders.WinLibs.POSIX.UCRT"

SetupGit $GitUser $GitEmail
SetupWSL $Distribution
SetupPowerShell
SetupStartAllBack "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Windows/StartAllBack/start-is-back.reg"
SetupWindHawk "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/WindHawk/windhawk-backup.zip"
SetupFont "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
SetupUnite "https://github.com/AyrtonAlbuquerque/Unite/releases/download/v1.0/Unite.exe"
SetupTheme "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Themes/One%20Dark.zip"

Execute { dotnet tool install --global dotnet-ef }

Write-Host "\nSetup completed. You must restart your computer to apply all changes."