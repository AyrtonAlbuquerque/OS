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
    [string]$Distribution = "Ubuntu-24.04",
    [string]$Browser = $null,
    [string]$BrowserVersion = $null
)

# ---------------------------------------- Functions ---------------------------------------- #
function OSVersion() {
    $version = [System.Environment]::OSVersion.Version

    if ($version.Major -eq 10 -and $version.Build -lt 22000) {
        return 10
    }

    return 11
}

function Install($package, [string]$version = $null) {
    Write-Host "---------------------- Installing $package ----------------------"

    try {
        $installed = winget list $package 2>$null

        if ($installed -match $package) {
            Write-Host "✔ $package is already installed."
            return
        }

        if ($version)
        {
            Start-Process "winget" -ArgumentList @("install", $package, "--version", $version) -Wait
        }
        else {
            Start-Process "winget" -ArgumentList @("install", $package) -Wait
        }
        
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
    # Execute { pwsh.exe -noprofile -command "git config --global user.name '$name'" }
    # Execute { pwsh.exe -noprofile -command "git config --global user.email '$email'" }
    Start-Process pwsh.exe -ArgumentList "-Command", "git config --global user.name '$GitUser'"
    Start-Process pwsh.exe -ArgumentList "-Command", "git config --global user.email '$GitEmail'"
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
            Execute { wsl --install -d $distribution }
        }
    }
    catch {
        Write-Warning "✖ Failed WSL2 installation: $_"
    }
}

function SetupStartAllBack($url) {
    try {
        $file = "$env:TEMP\start-is-back.reg"

        Install "StartIsBack.StartAllBack"
        Invoke-WebRequest -Uri $url -OutFile $file
        reg import $file
    }
    catch {
        Write-Warning "✖ Failed StartAllBack installation: $_"
    }
}

function SetupWindHawk($url) {
    try {
        if ((OSVersion) -eq 11) {
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
        else {
            Write-Host "WindHawk backup mods is only available for Windows 11."
        }
    }
    catch {
        Write-Warning "✖ Failed WindHawk installation: $_"
    }
}

function SetupStart11($url) {
    Write-Host "---------------------- Installing Start11 ----------------------"

    try {
        $start11 = "$env:TEMP\Start11.exe"
        $backup = "$env:USERPROFILE\Downloads\start11-backup.S11Backup"
        $image = "${env:ProgramFiles(x86)}\Stardock\Start11\StartButtons\Windows 11.png"
        $folder = Split-Path $image

        if (!(Test-Path $folder)) {
            New-Item -Path $folder -ItemType Directory -Force | Out-Null
        }

        Invoke-WebRequest -Uri $url -OutFile $start11
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Start11/start11-backup.S11Backup" -OutFile $backup
        Invoke-WebRequest -Uri "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Images/Windows%2011.png?download=" -OutFile $image
        Start-Process -FilePath $start11 -Wait
    }
    catch {
        Write-Warning "✖ Failed Start11 installation: $_"
    }
}

function SetupNilesoft {
    Write-Host "---------------------- Installing Nilesoft ----------------------"

    try {
        $root = "$env:ProgramFiles\Nilesoft Shell"
        $imports = "$env:ProgramFiles\Nilesoft Shell\imports"
        $shell = Join-Path $root "shell.nss"
        $theme = Join-Path $imports "theme.nss"

        Install "Nilesoft.Shell"

        if ((Test-Path $root)) {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Nilesoft/shell.nss" -OutFile $shell -ErrorAction Stop
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Nilesoft/theme.nss" -OutFile $theme -ErrorAction Stop
        }
    }
    catch {
        Write-Warning "✖ Failed Nilesoft installation: $_"
    }
}

function SetupExplorer($url) {
    Write-Host "---------------------- Installing Explorer ----------------------"

    $zip = "$env:TEMP\OldNewExplorer.zip"
    $folder = "$env:ProgramFiles"

    try {
        Invoke-WebRequest -Uri $url -OutFile $zip -ErrorAction Stop

        if (!(Test-Path $folder)) {
            New-Item -Path $folder -ItemType Directory -Force | Out-Null
        }

        Expand-Archive -Path $zip -DestinationPath $folder -Force
    }
    catch {
        Write-Warning "✖ Failed OldNewExplorer installation: $_"
    }
}

function SetupUI {
    try {
        if ((OSVersion) -eq 11) {
            SetupStartAllBack "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Windows/StartAllBack/start-is-back.reg"
            SetupWindHawk "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/WindHawk/windhawk-backup.zip"
        }
        else {
            # Install "CharlesMilette.TranslucentTB"
            Install "chanplecai.smarttaskbar"
            SetupExplorer "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/OldNewExplorer.zip"
            SetupNilesoft
            SetupStart11 "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Start11/Start11.exe"
        }
    }
    catch {
        Write-Warning "✖ Failed UI Setup: $_"
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
        $theme = "$env:TEMP\OneDark.zip"
        $reg = "$env:TEMP\explorer-colors.reg"
        $remove = "$env:TEMP\remove-folders.reg"
        $patcher = "$env:TEMP\ThemePatcher.exe"

        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Themes/explorer-colors.reg" -OutFile $reg
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Themes/remove-folders.reg" -OutFile $remove
        Invoke-WebRequest -Uri $url -OutFile $theme
        Invoke-WebRequest -Uri "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/Theme%20Patcher.exe" -OutFile $patcher
        Expand-Archive -Path $theme -DestinationPath "$env:WINDIR\Resources\Themes" -Force
        Start-Process -FilePath $patcher -Wait
        reg import $reg
        reg import $remove
    }
    catch {
        Write-Warning "✖ Failed Theme installation: $_"
    }
}

function SetupBrowser($browser, $version) {
    try {
        if ($browser) { 
            Install $browser $version
        }
    }
    catch {
        Write-Warning "✖ Failed Browser installation: $_"
    }
}

# ---------------------------------------- Execution ---------------------------------------- #
Install "Oracle.JDK.$Java"
Install "Python.Python.$Python"
Install "Microsoft.DotNet.SDK.$DotNet"
Install "Kitware.CMake"
Install "Docker.DockerDesktop"
Install "CoreyButler.NVMforWindows"
Install "Cygwin.Cygwin"

SetupGit $GitUser $GitEmail
SetupWSL $Distribution
SetupPowerShell
SetupFont "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
SetupUnite "https://github.com/AyrtonAlbuquerque/Unite/releases/download/v1.0/Unite.exe"
SetupTheme "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Themes/One%20Dark.zip"
SetupBrowser $Browser $BrowserVersion
SetupUI

Write-Host "Setup completed. You must restart your computer to apply all changes."
