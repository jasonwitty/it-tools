<picture>
    <source srcset="./.github/logo-dark.png" media="(prefers-color-scheme: light)">
    <source srcset="./.github/logo-white.png" media="(prefers-color-scheme: dark)">
    <img src="./.github/logo-dark.png" alt="logo">
</picture>

Useful tools for developer and people working in IT. [Have a look !](https://it-tools.tech).

**About This Fork**

This fork adds a streamlined workflow for tiling window managers (e.g., Hyprland, Sway, i3), a no‑chrome embed view for tools, and a Rofi script mode with per‑tool icons. It’s optimized for launching individual tools in app‑mode windows with clean keyboard‑driven navigation.

Highlights of this fork:
- Embed mode for any tool via `?embed=1` (minimal UI, dark background).
- Rofi integration with icons and a “🛠” tools menu mode.
- Desktop launchers for each tool (hidden from Applications via `NoDisplay=true`).

Demo (placeholder):

![Animated demo – TODO](docs/demo-animated.png)

---

## Quick Start (Docker)

Clone this fork (replace the URL with your fork if different), then build and run locally on port 8234:

```bash
git clone https://github.com/YOUR-USERNAME/it-tools.git
cd it-tools
docker build -t it-tools:embed .
docker run -d --name it-tools-embed --restart unless-stopped -p 8234:80 it-tools:embed
```

Open a tool in embed mode (no menu):

- Token Generator: `http://localhost:8234/token-generator?embed=1`
- UUID: `http://localhost:8234/uuid-generator?embed=1`

Notes:
- “Pretty” routes differ from folder names for some tools. Examples:
  - YAML Viewer → `/yaml-prettify`
  - QR Code Generator → `/qrcode-generator`
- The app’s router supports SPA refresh via Nginx `try_files`.

---

## Rofi Integration (tiling WM friendly)

This fork ships a generator that builds:
- A Rofi script mode (`~/.local/bin/rofi-it-tools`) listing all tools with icons.
- Per‑tool desktop entries (hidden from Applications).
- A “Tools: Menu” desktop entry that opens Rofi directly in the tools mode.

Prereqs:
- fish shell, rofi
- Chromium‑based browser (brave/chromium/google‑chrome)
- librsvg for SVG→PNG rasterization in Rofi (recommended)
  - Arch/CachyOS: `sudo pacman -S librsvg`
  - Debian/Ubuntu: `sudo apt install librsvg2-bin`

Generate launchers and menu:

```bash
fish ./generate-it-tools-launchers.fish
```

Launch the menu:

```bash
rofi -show-icons -modi "drun,🛠:$HOME/.local/bin/rofi-it-tools" -show 🛠
# or use the desktop entry "Tools: Menu"
# or the convenience script:
~/.local/bin/rofi-tools-menu
```

Make it default in Rofi (persistent):

- Create or edit `~/.config/rofi/config.rasi` and add one of the following:

Option A — Emoji mode name (recommended):

```rasi
configuration {
  show-icons: true;
  modi: "drun,🛠:/home/YOUR-USER/.local/bin/rofi-it-tools";
  kb-mode-next: "Control+Tab";
  kb-mode-previous: "Control+Shift+Tab";
}
```

Then run: `rofi -show 🛠`

Option B — Keep mode name "tools" but display an icon label:

```rasi
configuration {
  show-icons: true;
  modi: "drun,tools:/home/YOUR-USER/.local/bin/rofi-it-tools";
  display-tools: "🛠";
  kb-mode-next: "Control+Tab";
  kb-mode-previous: "Control+Shift+Tab";
}
```

Then run: `rofi -show tools`

Config overrides (`~/.config/it-tools/config.fish`):

```fish
set -x IT_TOOLS_BASE_URL "http://localhost:8234"
set -x IT_TOOLS_BROWSER_CMD brave         # or chromium/google-chrome
set -x IT_TOOLS_BROWSER_FLAGS "--disable-features=ExtensionsToolbarMenu,..."
set -x IT_TOOLS_PREFIX ""                 # optional prefix for Exec
set -x IT_TOOLS_MODI_LABEL "🛠"            # rofi mode label
```

Icons:
- Curated icons are seeded into `~/.config/it-tools/icons/` on each run.
- Drop‑in user overrides live in `~/.config/it-tools/icons.d/` (these always win).
- Rofi uses cached PNGs in `~/.config/it-tools/icons.cache/` for reliability.

Tips:
- Switch Rofi modes: `Ctrl+Tab` / `Ctrl+Shift+Tab` (configurable).
- The tools list shows clean names (no `tools/` prefix) with per‑tool icons.

---

## Embed Mode

Add `?embed=1` to any tool URL to render only the tool content, with a dark background and no menu/top bar. Examples:

- `http://localhost:8234/token-generator?embed=1`
- `http://localhost:8234/yaml-prettify?embed=1`

Accepted values: `1`, `true`, `yes`.

---

## Upstream Project README

The sections below are imported from the original project to keep upstream docs handy for reference. They may not describe fork‑specific behavior such as embed mode, Rofi tooling, or launcher generation.

## Functionalities and roadmap

Please check the [issues](https://github.com/CorentinTh/it-tools/issues) to see if some feature listed to be implemented.

You have an idea of a tool? Submit a [feature request](https://github.com/CorentinTh/it-tools/issues/new/choose)!

## Self host

Self host solutions for your homelab

**From docker hub:**

```sh
docker run -d --name it-tools --restart unless-stopped -p 8080:80 corentinth/it-tools:latest
```

**From github packages:**

```sh
docker run -d --name it-tools --restart unless-stopped -p 8080:80 ghcr.io/corentinth/it-tools:latest
```

**Other solutions:**

- [Cloudron](https://www.cloudron.io/store/tech.ittools.cloudron.html)
- [Tipi](https://www.runtipi.io/docs/apps-available)
- [Unraid](https://unraid.net/community/apps?q=it-tools)

## Contribute

### Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) with the following extensions:

- [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur)
- [TypeScript Vue Plugin (Volar)](https://marketplace.visualstudio.com/items?itemName=Vue.vscode-typescript-vue-plugin).
- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [i18n Ally](https://marketplace.visualstudio.com/items?itemName=lokalise.i18n-ally)

with the following settings:

```json
{
  "editor.formatOnSave": false,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "i18n-ally.localesPaths": ["locales", "src/tools/*/locales"],
  "i18n-ally.keystyle": "nested"
}
```

### Type Support for `.vue` Imports in TS

TypeScript cannot handle type information for `.vue` imports by default, so we replace the `tsc` CLI with `vue-tsc` for type checking. In editors, we need [TypeScript Vue Plugin (Volar)](https://marketplace.visualstudio.com/items?itemName=Vue.vscode-typescript-vue-plugin) to make the TypeScript language service aware of `.vue` types.

If the standalone TypeScript plugin doesn't feel fast enough to you, Volar has also implemented a [Take Over Mode](https://github.com/johnsoncodehk/volar/discussions/471#discussioncomment-1361669) that is more performant. You can enable it by the following steps:

1. Disable the built-in TypeScript Extension
   1. Run `Extensions: Show Built-in Extensions` from VSCode's command palette
   2. Find `TypeScript and JavaScript Language Features`, right click and select `Disable (Workspace)`
2. Reload the VSCode window by running `Developer: Reload Window` from the command palette.

### Project Setup

```sh
pnpm install
```

### Compile and Hot-Reload for Development

```sh
pnpm dev
```

### Type-Check, Compile and Minify for Production

```sh
pnpm build
```

### Run Unit Tests with [Vitest](https://vitest.dev/)

```sh
pnpm test
```

### Lint with [ESLint](https://eslint.org/)

```sh
pnpm lint
```

### Create a new tool

To create a new tool, there is a script that generate the boilerplate of the new tool, simply run:

```sh
pnpm run script:create:tool my-tool-name
```

It will create a directory in `src/tools` with the correct files, and a the import in `src/tools/index.ts`. You will just need to add the imported tool in the proper category and develop the tool.

## Contributors

Big thanks to all the people who have already contributed!

[![contributors](https://contrib.rocks/image?repo=corentinth/it-tools&refresh=1)](https://github.com/corentinth/it-tools/graphs/contributors)

## Credits

Coded with ❤️ by [Corentin Thomasset](https://corentin.tech?utm_source=it-tools&utm_medium=readme).

This project is continuously deployed using [vercel.com](https://vercel.com).

Contributor graph is generated using [contrib.rocks](https://contrib.rocks/preview?repo=corentinth/it-tools).

<a href="https://www.producthunt.com/posts/it-tools?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-it&#0045;tools" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=345793&theme=light" alt="IT&#0032;Tools - Collection&#0032;of&#0032;handy&#0032;online&#0032;tools&#0032;for&#0032;devs&#0044;&#0032;with&#0032;great&#0032;UX | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>
<a href="https://www.producthunt.com/posts/it-tools?utm_source=badge-top-post-badge&utm_medium=badge&utm_souce=badge-it&#0045;tools" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/top-post-badge.svg?post_id=345793&theme=light&period=daily" alt="IT&#0032;Tools - Collection&#0032;of&#0032;handy&#0032;online&#0032;tools&#0032;for&#0032;devs&#0044;&#0032;with&#0032;great&#0032;UX | Product Hunt" style="width: 250px; height: 54px;" width="250" height="54" /></a>

## License

This project is under the [GNU GPLv3](LICENSE).
