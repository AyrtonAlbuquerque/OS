# ------------------------------------------------------------------------------------------- #
#                                     Windows Setup Script                                    #
# ------------------------------------------------------------------------------------------- #

# ---------------------------------------- Parameters ---------------------------------------- #
param (
    [string]$Java = "24",
    [string]$Python = "3.13",
    [string]$DotNet = "9",
    [string]$Browser = $null,
    [string]$GitUser = $null,
    [string]$GitEmail = $null
)

# ---------------------------------------- Functions ---------------------------------------- #
function OSVersion() {
    $version = [System.Environment]::OSVersion.Version

    if ($version.Major -eq 10 -and $version.Build -lt 22000) {
        return 10
    }

    return 11
}

function RefreshPath() {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
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
        RefreshPath
        & $action
        Write-Host "✔ Success"
    }
    catch {
        Write-Warning "✖ Failed: $_"
    }
}

function Download($url, $path) {
    Write-Host "---------------------- Downloading $url ----------------------"

    $attempt = 0
    $directory = Split-Path -Path $path -Parent

    if (!(Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    while ($attempt -lt 5) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $path
            Write-Host "✔ Success"

            return $path
        }
        catch {
            $attempt++
            Write-Warning "✖ Download Failed, Retrying in 5 seconds...: $_"
            Start-Sleep -Seconds 5
        }
    }
}

function SetupGit($name, $email) {
    Install "Git.Git"

    if ($name) {
        Execute { pwsh.exe -noprofile -command "git config --global user.name '$name'" }
    }

    if ($email) {
        Execute { pwsh.exe -noprofile -command "git config --global user.email '$email'" }
    }
}

function SetupPowerShell() {
    $configuration = @(
        'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\craver.omp.json" | Invoke-Expression',
        'Import-Module posh-git',
        'Set-PSReadLineOption -PredictionSource History',
        'Set-PSReadLineOption -PredictionViewStyle ListView'
    )

    Install "Microsoft.PowerShell"
    Install "Microsoft.WindowsTerminal"
    Install "JanDeDobbeleer.OhMyPosh"
    Execute { pwsh.exe -noprofile -command "Install-Module oh-my-posh -Force" }
    Execute { pwsh.exe -noprofile -command "Install-Module posh-git -Force" }
    Execute { pwsh.exe -noprofile -command "Install-Module PSReadLine -Force" }
    Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Terminal/terminal.json" "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

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

function SetupWSL() {
    Write-Host "---------------------- Installing WSL2 ----------------------"
    
    try {
        if ((OSVersion) -eq 10) {
            $installer = Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/WSL%20Update.msi" "$env:TEMP\wsl_update_x64.msi"

            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
            Start-Process msiexec.exe -ArgumentList "/i `"$installer`" /quiet /norestart" -Wait
            Write-Host "✔ Success. After rebooting, install a distribution: wsl --install -d Ubuntu-24.04"
        }
        else {
            Execute { wsl --install --no-distribution }
            Execute { wsl --set-default-version 2 }
        }
    }
    catch {
        Write-Warning "✖ Failed WSL2 installation: $_"
    }
}

function SetupMinGW($url) {
    Write-Host "---------------------- Installing MinGW ----------------------"

    try {
        $mingw = Download $url "$env:TEMP\mingwInstaller.exe"
        $bin = "$env:USERPROFILE\mingw64\bin"
        $path = [Environment]::GetEnvironmentVariable("Path", "User")

        Start-Process -FilePath $mingw -Wait

        if ($path -notlike "*$bin*") {
            $bin = "$path;$bin"
            [Environment]::SetEnvironmentVariable("Path", $bin, "User")
        }
        else {
            Write-Host "$bin is already in the PATH."
        }
    }
    catch {
        Write-Warning "✖ Failed MinGW installation: $_"
    }
}

function SetupStartAllBack($url) {
    try {
        $file = Download $url "$env:TEMP\start-is-back.reg"

        Install "StartIsBack.StartAllBack"
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
            $file = Download $url "$env:TEMP\windhawk-backup.zip"
            $folder = Join-Path $env:TEMP "WindhawkRestore"
        
            Install "RamenSoftware.Windhawk"
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
    if ((OSVersion) -eq 10) {
        Write-Host "---------------------- Installing Start11 ----------------------"

        try {
            $start11 = Download $url "$env:TEMP\Start11.exe"
            $backup = Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Start11/start11-backup.S11Backup" "$env:USERPROFILE\Downloads\start11-backup.S11Backup"
            $image = Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Images/Windows%2011.png?download=" "${env:ProgramFiles(x86)}\Stardock\Start11\StartButtons\Windows 11.png"
            $folder = Split-Path $image

            if (!(Test-Path $folder)) {
                New-Item -Path $folder -ItemType Directory -Force | Out-Null
            }

            Start-Process -FilePath $start11
        }
        catch {
            Write-Warning "✖ Failed Start11 installation: $_"
        }           
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
            Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Nilesoft/shell.nss" $shell
            Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Nilesoft/theme.nss" $theme
        }
    }
    catch {
        Write-Warning "✖ Failed Nilesoft installation: $_"
    }
}

function SetupExplorer($url) {
    Write-Host "---------------------- Installing Explorer ----------------------"

    try {
        $zip = Download $url "$env:TEMP\OldNewExplorer.zip"
        $folder = "$env:ProgramFiles"

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
            $context = 'HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'

            SetupStartAllBack "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Windows/StartAllBack/start-is-back.reg"
            SetupWindHawk "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/WindHawk/windhawk-backup.zip"

            if (Test-Path -Path $context) {
                Remove-Item -Path $context -Recurse -Force
            }
        }
        else {
            Install "chanplecai.smarttaskbar"
            Install "gerardog.gsudo"
            SetupExplorer "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/OldNewExplorer.zip"
            SetupNilesoft
            Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Icons/7TSP%20Windows%2011.7z" "$env:USERPROFILE\Downloads\7TSP Windows 11.7z"
            Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Icons/7tsp.exe" "$env:USERPROFILE\Downloads\7tsp.exe"
        }

        Download "https://media.githubusercontent.com/media/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Wallpaper/Wallpapper.png" "$env:USERPROFILE\Pictures\Wallpapper.png"
        Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Wallpaper/Wallpaper.mp4" "$env:USERPROFILE\Videos\Wallpaper.mp4"
        $zip = Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Cursor/Modern.zip" "$env:USERPROFILE\Downloads\Modern.zip"
        Expand-Archive -Path $zip -DestinationPath "$env:USERPROFILE\Downloads\Cursor" -Force
    }
    catch {
        Write-Warning "✖ Failed UI Setup: $_"
    }
}

function SetupFont($url) {
    Write-Host "---------------------- Installing Font ----------------------"

    try {
        $file = Download $url "$env:TEMP\FiraCode.zip"
        $folder = "$env:TEMP\FiraCodeFonts"

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
            Download $url $target
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
        $theme = Download $url "$env:TEMP\OneDark.zip"
        $reg = Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Themes/explorer-colors.reg" "$env:TEMP\explorer-colors.reg"
        $remove = Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Themes/remove-folders.reg" "$env:TEMP\remove-folders.reg"
        $patcher = Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/Theme%20Patcher.exe" "$env:TEMP\ThemePatcher.exe"

        Expand-Archive -Path $theme -DestinationPath "$env:WINDIR\Resources\Themes" -Force
        Start-Process -FilePath $patcher -Wait
        reg import $reg
        reg import $remove
    }
    catch {
        Write-Warning "✖ Failed Theme installation: $_"
    }
}

function SetupBrowser($browser) {
    try {
        if ($browser) { 
            if ($browser -eq "Zen-Team.Zen-Browser") {
                $root = "${env:ProgramFiles}\Zen Browser"
                $icon = Join-Path $root "firefox.ico"
                $distribution = Join-Path $root "distribution"
                $policies = Join-Path $distribution "policies.json"

                Install $browser "1.0.1-a.22"

                if (!(Test-Path $distribution)) {
                    New-Item -ItemType Directory -Path $distribution -Force | Out-Null
                }

                Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/firefox.ico" $icon
                Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/distribution/policies.json" $policies
                Download "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Browser/Extensions/Infinity%20New%20Tab.xpi" "$env:USERPROFILE\Downloads\Infinity New Tab.xpi"
                Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/Setup.txt" "$env:USERPROFILE\Downloads\Setup.txt"
                Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/Configuration/AdBlocker.txt" "$env:USERPROFILE\Downloads\AdBlocker.txt"
                Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/Configuration/Enhancer%20for%20Youtube.json" "$env:USERPROFILE\Downloads\Enhancer for Youtube.json"
                Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/Configuration/inifinity-backup.infinity" "$env:USERPROFILE\Downloads\inifinity-backup.infinity"
                Execute { pwsh.exe -noprofile -command "winget pin add Zen-Team.Zen-Browser" }

                $zen = Join-Path $root "zen.exe"

                if (Test-Path $zen) {
                    Start-Process -FilePath $zen -WindowStyle Minimized
                    Start-Sleep -Seconds 5
                    Get-Process -Name "zen" -ErrorAction SilentlyContinue | Stop-Process -Force
                }

                $profiles = "$env:APPDATA\zen\Profiles"

                if (Test-Path $profiles) {
                    $defaultProfile = Get-ChildItem -Path $profiles -Directory | Where-Object { $_.Name -like "*(alpha)" } | Select-Object -First 1
                    
                    if ($defaultProfile) {
                        $chromeFolder = Join-Path $defaultProfile.FullName "chrome"
                        
                        if (!(Test-Path $chromeFolder)) {
                            New-Item -ItemType Directory -Path $chromeFolder -Force | Out-Null
                        }

                        $userChromeFile = Join-Path $chromeFolder "userChrome.css"
                        Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/userChrome.css" $userChromeFile
                    }
                    else {
                        Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/userChrome.css" "$env:USERPROFILE\Downloads\userChrome.css"
                    }
                }
                else {
                    Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Browser/userChrome.css" "$env:USERPROFILE\Downloads\userChrome.css"
                }
            }
            else {
                Install $browser
            }
        }
    }
    catch {
        Write-Warning "✖ Failed Browser installation: $_"
    }
}

function SetupInsomnia($url) {
    Write-Host "---------------------- Installing Insomnia ----------------------"
    
    try {
        $insomnia = Download $url "$env:TEMP\Insomnia.exe"

        Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Utilities/Insomnia/Insomnia" "$env:USERPROFILE\Downloads\Insomnia"
        Download "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/refs/heads/main/Windows/Utilities/Insomnia/index.js" "$env:USERPROFILE\Downloads\index.js"
        Start-Process -FilePath $insomnia -Wait
    }
    catch {
        Write-Warning "✖ Failed Insomnia installation: $_"
    }
}

function SetupApplications($option) {
    switch ($option.ToUpper()) {
        'Y' { 
            Install "Microsoft.VisualStudioCode"
            Install "JetBrains.Toolbox"
            Install "TortoiseGit.TortoiseGit"
            Install "Stremio.StremioService"
            Install "BlastApps.FluentSearch"
            Install "Docker.DockerDesktop"
            SetupInsomnia "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/Insomnia.exe"
            SetupStart11 "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Start11/Start11.exe"

            Write-Host "Done! You must restart your computer to apply the changes." 
        }
        'N' { Write-Host "Done! You must restart your computer to apply the changes." }
        Default { Write-Host "Invalid input. Exiting." }
    }
}

# ---------------------------------------- Execution ---------------------------------------- #
Install "Oracle.JDK.$Java"
Install "Python.Python.$Python"
Install "Microsoft.DotNet.SDK.$DotNet"
Install "Kitware.CMake"
Install "CoreyButler.NVMforWindows"

Execute { pwsh.exe -noprofile -command "dotnet tool install --global dotnet-ef" }

SetupGit $GitUser $GitEmail
SetupWSL
SetupPowerShell
SetupMinGW "https://github.com/Vuniverse0/mingwInstaller/releases/download/1.2.1/mingwInstaller.exe"
SetupFont "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
SetupUnite "https://github.com/AyrtonAlbuquerque/Unite/releases/download/v1.0/Unite.exe"
SetupTheme "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Themes/One%20Dark.zip"
SetupBrowser $Browser
SetupUI

Write-Host "Setup completed. Do you wish to install extra tools?"
$action = Read-Host "(y/n)"
SetupApplications $action