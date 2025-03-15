<div align="center">

# 🖥️ Windows Setup Script - User Guide

</div>

## 📄 Overview
This PowerShell script is a fully automated setup tool for configuring a fresh Windows installation. It installs essential development tools, configures Git and PowerShell, sets up WSL2, applies themes, and more — all in one pass.

The script is hosted in this repository:
👉 [GitHub - OS](https://github.com/AyrtonAlbuquerque/OS/blob/main/Windows/setup.ps1)

---

## ⚙️ Features
- Installs Git and configures global identity
- Installs and configures PowerShell with themes, PSReadLine, and posh-git
- Installs WSL2 (supports version detection)
- Installs essential developer tools:
  - Python
  - Java JDK
  - .NET SDK and Entity Framework
  - CMake, MinGW, Docker, NVM
- Configures StartAllBack UI enhancements
- Restores Windhawk configuration from backup
- Installs FiraCode Nerd Font
- Applies One Dark Windows theme
- Adds Unite tool to Startup folder

---

## 🚀 How to Use

### ⚠️ Important: Must run from an **elevated PowerShell terminal (Run as Administrator)**.

### ✅ Step 1: Execute the script from command line
You can download and run the script directly using the command below:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Windows/setup.ps1" -OutFile "$env:USERPROFILE\Downloads\setup.ps1"; powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup.ps1" -GitUser "Your Name" -GitEmail "your@email.com" -Java "23" -Python "3.13" -DotNet "9" -Distribution "Ubuntu-24.04"
```

You can customize the parameters if needed:

### 🧠 Available Parameters:
| Parameter        | Description                                 | Default Value               |
|------------------|---------------------------------------------|-----------------------------|
| `-GitUser`       | Git global username                         | `ayrton`                    |
| `-GitEmail`      | Git global email                            | `ayrton_ito@hotmail.com`    |
| `-Java`          | Java JDK version                            | `23`                        |
| `-Python`        | Python version                              | `3.13`                      |
| `-DotNet`        | .NET SDK version                            | `9`                         |
| `-Distribution`  | WSL2 Linux distribution                     | `Ubuntu-24.04`              |

### 🧪 Example:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Windows/setup.ps1" -OutFile "$env:USERPROFILE\Downloads\setup.ps1"; powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\setup.ps1" -GitUser "John Doe" -GitEmail "john@example.com" -Java "21" -Python "3.12" -DotNet "8" -Distribution "Ubuntu-22.04"
```

---

## 📎 Notes
- Some installers (e.g., Docker, StartAllBack) may show interactive windows.
- FiraCode font and Windhawk settings are restored silently.
- A reboot is recommended at the end of the script.

---

## 📬 Feedback / Contributions
Feel free to fork the repo, suggest improvements, or open issues here:
👉 [https://github.com/AyrtonAlbuquerque/OS](https://github.com/AyrtonAlbuquerque/OS)

---

## 🙌 Credits
Script and automation created by **Ayrton Albuquerque**.
Inspired by the best practices of modern Windows provisioning workflows.

