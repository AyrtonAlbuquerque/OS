<div align="center">

# 🖥️ Ubuntu Setup Script

</div>

## 📄 Overview
This shell script is a fully automated setup tool for configuring a fresh Ubuntu/WSL installation. It installs essential development tools, applies themes, and more — all in one pass.

The script is hosted in this repository:
👉 [GitHub - OS](https://github.com/AyrtonAlbuquerque/OS/blob/main/Ubuntu/setup.sh)

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
  - Applies One Dark theme
- Install a Browser of choice

---

## 🚀 How to Use

### ✅ Step 1: Execute the script from terminal
You can download and run the script directly using the command below:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/AyrtonAlbuquerque/OS/main/Ubuntu/setup.sh) \
  --git_user="namae" \
  --git_email="name@hotmail.com" \
  --git_credencial="store" \
  --python="3.13" \
  --dotnet="9" \
  --java="24" \
  --noui
```

You can customize the parameters if needed:

### 🧠 Available Parameters:
| Parameter         | Description                                 | Default Value               |
|-------------------|---------------------------------------------|-----------------------------|
| `--java`          | Java JDK version                            | `24`                        |
| `--python`        | Python version                              | `3.13`                      |
| `--dotnet`        | .NET SDK version                            | `9`                         |
| `--git_user`      | Git global username                         | `none`                      |
| `--git_email`     | Git global email                            | `none`                      |
| `--git_credencial`| Git credential                              | `none`                      |
| `--noui`          | Skips UI related settings (WSL2 setup)      | `none`                      |

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

