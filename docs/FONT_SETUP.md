# Font Setup - MesloLGS NF

This script does **not** install the font automatically. You must install **MesloLGS NF** manually before the prompt icons render correctly.

Without it, you will see `?` or boxes instead of icons in your terminal.

## Download

Download all 4 font files:

- [MesloLGS NF Regular](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

## Install the Font

### macOS

1. Download all 4 files above
2. Double-click each `.ttf` file → click **Install Font**
3. Or drag all files into **Font Book**

### Linux

```bash
mkdir -p ~/.local/share/fonts
cp MesloLGS*.ttf ~/.local/share/fonts/
fc-cache -fv
```

### WSL2

The font must be installed on your **Windows host**, not inside WSL:

1. Download all 4 files on Windows
2. Right-click each `.ttf` → **Install for all users**
3. Open your WSL terminal app (Windows Terminal, etc.) and set the font there

## Set the Font in Your Terminal

### macOS - iTerm2

`Preferences` → `Profiles` → `Text` → `Font` → select `MesloLGS NF`

### macOS - Terminal.app

`Terminal` → `Preferences` → `Profiles` → `Text` → `Change Font` → select `MesloLGS NF`

### Windows Terminal

Open `settings.json` and add under your WSL/profile:

```json
"fontFace": "MesloLGS NF"
```

### Alacritty

```yaml
font:
  normal:
    family: MesloLGS NF
```

### Kitty

```
font_family MesloLGS NF
```

## Set the Font in Your IDE Terminal

### VS Code

`Cmd+,` → search `terminal font` → set `Terminal › Integrated: Font Family` to `MesloLGS NF`

Or in `settings.json`:

```json
{
  "terminal.integrated.fontFamily": "MesloLGS NF"
}
```

### JetBrains IDEs (IntelliJ, WebStorm, GoLand, PyCharm, RustRover)

`Settings` → `Tools` → `Terminal` → `Font` → `MesloLGS NF`

## Verify

After setting the font, open a new terminal. You should see icons in your prompt instead of `?` or boxes. If not, restart your terminal app completely.
