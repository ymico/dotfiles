# .dotfiles — Amethyst Pixel Rice

A pixel-art and amethyst-themed desktop environment configuration for **Hyprland** on **Fedora Linux**.

---

## Overview

- **OS:** Fedora Linux (x86_64)
- **WM:** [Hyprland](https://hyprland.org/)
- **Bar:** [Waybar](https://github.com/Alexays/Waybar) (Pixel Amethyst Edition)
- **Terminal:** [Ghostty](https://ghostty.org/)
- **Shell:** Zsh
- **Launcher:** [Rofi](https://github.com/davatorium/rofi)
- **Notifications:** [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
- **Fetch:** [Fastfetch](https://github.com/fastfetch-cli/fastfetch) with custom Amethyst sigil

---

## Palette & Design

| Color Name | Hex Code | Preview |
|---|---|---|
| Background | `#0e0a14` | Dark Violet |
| Amethyst Primary | `#bb9af7` | Bright Purple |
| Accent Lavender | `#c0caf5` | Soft Lavender |
| Surface Deep | `#161120` | Panel Surface |
| Cyan Glow | `#7dcfff` | Secondary Accent |

---

## Structure

```text
.
├── .config/
│   ├── hypr/               # Hyprland window rules, keybindings, animations
│   ├── waybar/             # Status bar config and pixel amethyst CSS
│   ├── ghostty/            # Ghostty terminal styling and transparency
│   ├── fastfetch/          # Custom fastfetch layout and sigil logo
│   ├── rofi/               # Application launcher theme
│   ├── swaync/             # Control center & notification styling
│   └── custom-sound-mixer/ # Amethyst audio panel theme
├── .zshrc                  # Zsh prompt and aliases
└── README.md
```

---

## Installation

```bash
git clone https://github.com/ymico/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Link configs
cp -r .config/* ~/.config/
cp .zshrc ~/
```

---

## License

MIT © [ymico](https://github.com/ymico)
