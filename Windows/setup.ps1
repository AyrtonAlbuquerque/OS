# Automated Setup Script (Requires Elevated Terminal)

function Try-Run($ActionDescription, [scriptblock]$Action) {
    Write-Host "--- $ActionDescription ---"
    try {
        & $Action
        Write-Host "✔ Success: $ActionDescription"
    } catch {
        Write-Warning "✖ Failed: $ActionDescription - $_"
    }
}

# ----------------------------
# Step 1: Install Git & Configure
# ----------------------------
Try-Run "Installing Git" { Start-Process "winget" -ArgumentList "install Git.Git" -Wait }
Try-Run "Configuring Git user.name" { git config --global user.name "ayrton" }
Try-Run "Configuring Git user.email" { git config --global user.email "ayrton_ito@hotmail.com" }

# ----------------------------
# Step 2: Install PowerShell Modules and Oh-My-Posh
# ----------------------------
Try-Run "Installing PowerShell" { Start-Process "winget" -ArgumentList "install Microsoft.PowerShell" -Wait }
Try-Run "Installing PSReadLine prerelease" { pwsh.exe -noprofile -command "Install-Module PSReadLine -Force -AllowPrerelease -SkipPublisherCheck" }
Try-Run "Installing oh-my-posh" { pwsh.exe -noprofile -command "Install-Module oh-my-posh -Force" }
Try-Run "Installing posh-git" { pwsh.exe -noprofile -command "Install-Module posh-git -Force" }
Try-Run "Reinstalling PSReadLine" { pwsh.exe -noprofile -command "Install-Module PSReadLine -Force" }
Try-Run "Installing OhMyPosh via Winget" { Start-Process "winget" -ArgumentList "install JanDeDobbeleer.OhMyPosh" -Wait }

# Configure PowerShell Profile
Try-Run "Configuring PowerShell profile" {
    $profileLines = @(
        'oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\craver.omp.json" | Invoke-Expression',
        'Import-Module posh-git',
        'Set-PSReadLineOption -PredictionSource History',
        'Set-PSReadLineOption -PredictionViewStyle ListView'
    )
    if (!(Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
    Add-Content -Path $PROFILE -Value $profileLines
}

# ----------------------------
# Step 3: Install WSL2
# ----------------------------
Try-Run "Installing WSL2" {
    $osVersion = [System.Environment]::OSVersion.Version

    if ($osVersion.Major -eq 10 -and $osVersion.Build -lt 22000) {
        $wslKernelInstaller = "$env:TEMP\wsl_update_x64.msi"
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile $wslKernelInstaller
        Start-Process msiexec.exe -ArgumentList "/i `"$wslKernelInstaller`" /quiet /norestart" -Wait
    } else {
        wsl --install -d Ubuntu-24.04
    }
}

# ----------------------------
# Step 4-16: Winget installs and other configurations
$installSteps = @(
    @{ Name = "Install MinGW"; Cmd = { Start-Process "winget" -ArgumentList "install BrechtSanders.WinLibs.POSIX.UCRT" -Wait } },
    @{ Name = "Install CMake"; Cmd = { Start-Process "winget" -ArgumentList "install Kitware.CMake" -Wait } },
    @{ Name = "Install NVM"; Cmd = { Start-Process "winget" -ArgumentList "install CoreyButler.NVMforWindows" -Wait } },
    @{ Name = "Install Python"; Cmd = { Start-Process "winget" -ArgumentList "install Python.Python.3.13" -Wait } },
    @{ Name = "Install Java"; Cmd = { Start-Process "winget" -ArgumentList "install Oracle.JDK.23" -Wait } },
    @{ Name = "Install .NET SDK"; Cmd = { Start-Process "winget" -ArgumentList "install Microsoft.DotNet.SDK.9" -Wait } },
    @{ Name = "Install Docker"; Cmd = { Start-Process "winget" -ArgumentList "install Docker.DockerDesktop" -Wait } },
    @{ Name = "Install StartAllBack"; Cmd = { Start-Process "winget" -ArgumentList "install StartIsBack.StartAllBack" -Wait } },
    @{ Name = "Install Windhawk"; Cmd = { Start-Process "winget" -ArgumentList "install RamenSoftware.Windhawk" -Wait } }
)

foreach ($step in $installSteps) {
    Try-Run $step.Name $step.Cmd
}

Try-Run "Install Entity Framework Tool" { dotnet tool install --global dotnet-ef }

Try-Run "Import StartAllBack Registry" {
    $regUrl = "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Windows/StartAllBack/start-is-back.reg"
    $regFile = "$env:TEMP\start-is-back.reg"
    Invoke-WebRequest -Uri $regUrl -OutFile $regFile
    reg import $regFile
}

Try-Run "Restore Windhawk Backup" {
    $windhawkZip = "$env:TEMP\windhawk-backup.zip"
    Invoke-WebRequest -Uri "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/WindHawk/windhawk-backup.zip" -OutFile $windhawkZip
    $windhawkRoot = "C:\ProgramData\Windhawk"
    $extractFolder = Join-Path $env:TEMP "WindhawkRestore"
    Expand-Archive -Path $windhawkZip -DestinationPath $extractFolder -Force
    Copy-Item "$extractFolder\ModsSource" -Destination $windhawkRoot -Recurse -Force
    if (!(Test-Path "$windhawkRoot\Engine")) { New-Item -ItemType Directory -Path "$windhawkRoot\Engine" -Force | Out-Null }
    Copy-Item "$extractFolder\Engine\Mods" -Destination "$windhawkRoot\Engine" -Recurse -Force
    if (Test-Path "$extractFolder\Windhawk.reg") { reg import "$extractFolder\Windhawk.reg" }
}

Try-Run "Install FiraCode Nerd Font" {
    $fontZip = "$env:TEMP\FiraCode.zip"
    $fontExtract = "$env:TEMP\FiraCodeFonts"
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip" -OutFile $fontZip
    Expand-Archive -Path $fontZip -DestinationPath $fontExtract -Force
    $fonts = Get-ChildItem -Path $fontExtract -Recurse -Include *.ttf, *.otf
    foreach ($font in $fonts) {
        Copy-Item $font.FullName -Destination "$env:WINDIR\Fonts" -Force
        $name = [System.IO.Path]::GetFileNameWithoutExtension($font.Name)
        $type = if ($font.Extension -eq ".ttf") { " (TrueType)" } elseif ($font.Extension -eq ".otf") { " (OpenType)" } else { "" }
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$name$type" -Value $font.Name -PropertyType String -Force | Out-Null
    }
}

Try-Run "Install One Dark Theme" {
    $themeZip = "$env:TEMP\OneDark.zip"
    Invoke-WebRequest -Uri "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Themes/One%20Dark.zip" -OutFile $themeZip
    Expand-Archive -Path $themeZip -DestinationPath "$env:WINDIR\Resources\Themes" -Force
}

Try-Run "Install Theme Patcher" {
    $patcherExe = "$env:TEMP\ThemePatcher.exe"
    Invoke-WebRequest -Uri "https://github.com/AyrtonAlbuquerque/OS/raw/refs/heads/main/Windows/Programs/Theme%20Patcher.exe" -OutFile $patcherExe
    Start-Process -FilePath $patcherExe -Wait
}

# ----------------------------
# Step 17: End
# ----------------------------
Write-Host "\nSetup completed. You must restart your computer to apply all changes."
