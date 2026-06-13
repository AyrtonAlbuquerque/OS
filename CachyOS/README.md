<div align="center">

# 🖥️ CachyOS Setup Script

</div>

## 📄 Overview
This shell script is a fully automated setup tool for configuring a fresh CachyOS/WSL installation. It installs essential development tools, applies themes, and more — all in one pass.

The script is hosted in this repository:
👉 [GitHub - OS](https://github.com/AyrtonAlbuquerque/OS/blob/main/CachyOS/setup.sh)

---

## ⚙️ Features
- Installs Git and configures global identity
- Installs and configures ZSH with themes, zsh-autosuggestions, and oh-my-posh
- Installs essential developer tools:
  - Python
  - Java JDK
  - .NET SDK and Entity Framework
  - CMake, MinGW, Docker, NVM
- Configures UI extensions (use `--noui` to skip (for WSL2 installs))
  - Installs FiraCode Nerd Font
- Install Zen Browser with custom configurations

---

## 🚀 How to Use

### ✅ Step 1: Update and install core libraries

```bash
sudo pacman -Syu --noconfirm && \
sudo pacman -S --noconfirm --needed \
  base-devel curl unzip gnupg \
  ca-certificates git gcc gdb wmctrl cmake \
  python-pipx zsh && \
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### ✅ Step 2: After a reboot, install Konsave using pipx
```bash
pipx ensurepath && pipx install konsave && source ~/.zshrc
```

### ✅ Step 3: Execute the script from terminal
You can download and run the script directly using the command below:

```bash
wget https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/CachyOS/setup.sh && \
zsh setup.sh \
  --git_user="ayrton" \
  --git_email="ayrton_ito@hotmail.com" \
  --dotnet="10" \
  --noui
```

You can customize the parameters if needed:

### 🧠 Available Parameters:
| Parameter          | Description                            | Default Value |
| ------------------ | -------------------------------------- | ------------- |
| `--dotnet`         | .NET SDK version                       | `10`          |
| `--git_user`       | Git global username                    | `none`        |
| `--git_email`      | Git global email                       | `none`        |
| `--noui`           | Skips UI related settings (WSL2 setup) | `none`        |

---

## 📎 Notes
- A reboot is necessary after executing  the script.

---

## 📬 Feedback / Contributions
Feel free to fork the repo, suggest improvements, or open issues here:
👉 [https://github.com/AyrtonAlbuquerque/OS](https://github.com/AyrtonAlbuquerque/OS)

---

## 🙌 Credits
Script and automation created by **Ayrton Albuquerque**.

