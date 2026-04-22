<div align="center">

# 🖥️ Windows Setup Script

</div>

## 📄 Overview
This PowerShell script is a fully automated setup tool for configuring a fresh Windows installation. It installs essential development tools, configures Git and PowerShell, sets up WSL2, applies themes, and more — all in one pass.

The script is hosted in this repository:
👉 [GitHub - OS](https://github.com/AyrtonAlbuquerque/OS/blob/main/Windows/setup.ps1)

---

## ⚙️ Features
- Installs Git and configures global identity
- Installs and configures PowerShell with themes, PSReadLine, and posh-git
- Installs WSL2
- Installs essential developer tools:
  - Python
  - Java JDK
  - .NET SDK and Entity Framework
  - CMake, MinGW, Docker, NVM
- Restores Windhawk configuration from backup
- Installs FiraCode Nerd Font
- Applies One Dark Windows theme
- Adds Unite tool to Startup folder
- Install a Browser of choice

---

## 🚀 How to Use

### ⚠️ Important: Must run from an **elevated PowerShell terminal (Run as Administrator)**.

### ✅ Step 1: Execute the script from command line
You can download and run the script directly using the command below:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Windows/setup.ps1" -OutFile "$env:USERPROFILE\Downloads\setup.ps1"; pwsh.exe -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup.ps1" -Java "26" -Python "3.14" -DotNet "10" -Dock "MyDockFinder" -Browser "Zen-Team.Zen-Browser" -GitUser "ayrton" -GitEmail "ayrton_ito@hotmail.com"
```

You can customize the parameters if needed:

### 🧠 Available Parameters:
| Parameter   | Description                                                  | Default Value |
| ----------- | ------------------------------------------------------------ | ------------- |
| `-Java`     | Java JDK version                                             | `26`          |
| `-Python`   | Python version                                               | `3.14`        |
| `-DotNet`   | .NET SDK version                                             | `10`          |
| `-Dock`     | Dock of choice (MyDockFinder, ObjectDock, NexusDock, Seelen) | `none`        |
| `-Browser`  | Browser of choice (Winget Id)                                | `none`        |
| `-GitUser`  | Git global username                                          | `none`        |
| `-GitEmail` | Git global email                                             | `none`        |

---

## 📎 Notes
- Some installers may show interactive windows.
- FiraCode font and Windhawk settings are restored silently.
- A reboot is necessary after executing  the script.

---

## 📬 Feedback / Contributions
Feel free to fork the repo, suggest improvements, or open issues here:
👉 [https://github.com/AyrtonAlbuquerque/OS](https://github.com/AyrtonAlbuquerque/OS)

---

## 🙌 Credits
Script and automation created by **Ayrton Albuquerque**.
Inspired by the best practices of modern Windows provisioning workflows.

