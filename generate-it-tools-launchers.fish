#!/usr/bin/env fish
# Generate rofi + desktop launchers for it-tools from src/tools/*
# Run this from the it-tools project root.

function log
  set -l ts (date "+%H:%M:%S")
  echo "[$ts]" $argv
end

log "Starting IT-Tools launcher generation"

set -l TOOLS_DIR src/tools
test -d $TOOLS_DIR; or begin
  echo "Error: run from repo root; $TOOLS_DIR not found." >&2
  exit 1
end

# Output locations
set -g APPS_DIR $HOME/.local/share/applications
set -g BIN_DIR $HOME/.local/bin
set -g CFG_DIR $HOME/.config/it-tools
set -g ICONS_DIR $CFG_DIR/icons
set -g ICONS_DROP_DIR $CFG_DIR/icons.d
set -g ICONS_CACHE_DIR $CFG_DIR/icons.cache

mkdir -p $APPS_DIR $BIN_DIR $CFG_DIR
mkdir -p $ICONS_DIR $ICONS_DROP_DIR $ICONS_CACHE_DIR
log "Using config dir: $CFG_DIR"
log "Output apps dir: $APPS_DIR"
log "Output bin dir:  $BIN_DIR"

# Load optional user config to override defaults
if test -f $CFG_DIR/config.fish
  log "Loading config: $CFG_DIR/config.fish"
  source $CFG_DIR/config.fish
else
  log "No user config file found (optional): $CFG_DIR/config.fish"
end

# Rofi mode label (emoji allowed); override with IT_TOOLS_MODI_LABEL
if set -q IT_TOOLS_MODI_LABEL
  set -l MODI_LABEL $IT_TOOLS_MODI_LABEL
else
  set -l MODI_LABEL "🛠"
end

# Where your container is serving the embed build
if set -q IT_TOOLS_BASE_URL
  set -g BASE_URL $IT_TOOLS_BASE_URL
else
  set -g BASE_URL "http://localhost:8234"
end
log "Base URL: $BASE_URL"

# Browser command (default brave, can be overridden)
# Override by exporting IT_TOOLS_BROWSER_CMD, e.g., "chromium" or "google-chrome"
set -l BROWSER_CMD "brave"
if set -q IT_TOOLS_BROWSER_CMD
  set -l BROWSER_CMD $IT_TOOLS_BROWSER_CMD
else if not type -q brave
  if type -q chromium
    set -l BROWSER_CMD chromium
  else if type -q google-chrome
    set -l BROWSER_CMD google-chrome
  end
end
log "Browser command: $BROWSER_CMD"

# App-mode flags shared by Chromium-based browsers
set -l DEFAULT_BROWSER_FLAGS "--disable-features=ExtensionsToolbarMenu,BraveVPN,Binance,Doodles,BinanceStaking,VpnServices,BraveTalk,Flock,SocialMediaEngagement,BinanceWidget,PeerConnectionKeying,DirectSockets,DownstreamWithoutOrigin,PaymentService,WebXRGamepadModule,WebXRHitTest"
set -l EFFECTIVE_BROWSER_FLAGS $DEFAULT_BROWSER_FLAGS
if set -q IT_TOOLS_BROWSER_FLAGS
  set -l EFFECTIVE_BROWSER_FLAGS $IT_TOOLS_BROWSER_FLAGS
end
set -l BROWSER_CMDLINE "$BROWSER_CMD --app=%URL% $EFFECTIVE_BROWSER_FLAGS"
log "Browser flags: $EFFECTIVE_BROWSER_FLAGS"

# If you really need the "[tile]" prefix for your WM, add it here:
# set -l PREFIX "[tile] "
if set -q IT_TOOLS_PREFIX
  set -l PREFIX $IT_TOOLS_PREFIX
else
  set -l PREFIX ""  # empty by default
end
test -n "$PREFIX"; and log "Prefix set: '$PREFIX'"

# Install or pick an icon for desktop entries
set -l ICON_PATH "$CFG_DIR/icon.png"
if set -q IT_TOOLS_ICON
  set -l ICON_PATH $IT_TOOLS_ICON
else if not test -f $ICON_PATH
  if test -f public/android-chrome-192x192.png
    cp -f public/android-chrome-192x192.png $ICON_PATH
  end
end
if test -f $ICON_PATH
  log "Icon file: $ICON_PATH"
else
  log "No custom icon file; will use theme icons per category"
end

# Seed a curated set of per-tool icons into $ICONS_DIR (non-destructive)
log "Seeding default per-tool icons (non-destructive). Drop-in overrides in $ICONS_DROP_DIR"
function seed_default_icons
  set -l repo (pwd)
  set -l src "$repo/assets/tool-icons"
  set -l pairs \
    token-generator:crypto.svg \
    basic-auth-generator:key.svg \
    bcrypt:crypto.svg \
    hmac-generator:crypto.svg \
    rsa-key-pair-generator:crypto.svg \
    jwt-parser:shield.svg \
    uuid-generator:id.svg \
    ulid-generator:id.svg \
    qr-code-generator:qr.svg \
    wifi-qr-code-generator:wifi.svg \
    url-parser:link.svg \
    url-encoder:link.svg \
    json-viewer:braces.svg \
    yaml-viewer:braces.svg \
    xml-formatter:brackets.svg \
    json-to-xml:brackets.svg \
    xml-to-json:braces.svg \
    json-minify:braces.svg \
    text-diff:diff.svg \
    text-statistics:text.svg \
    string-obfuscator:text.svg \
    color-converter:palette.svg \
    svg-placeholder-generator:photo.svg \
    html-wysiwyg-editor:code.svg \
    crontab-generator:time.svg \
    date-time-converter:time.svg \
    math-evaluator:sigma.svg \
    sql-prettify:table.svg \
    ipv4-subnet-calculator:network.svg \
    ipv4-address-converter:network.svg \
    ipv4-range-expander:network.svg \
    ipv6-ula-generator:network.svg \
    mac-address-lookup:network.svg \
    random-port-generator:random.svg \
    keycode-info:keyboard.svg \
    device-information:chip.svg \
    emoji-picker:emoji.svg \
    ascii-text-drawer:text.svg \
    base64-file-converter:braces.svg \
    base64-string-converter:braces.svg \
    benchmark-builder:time.svg \
    bip39-generator:id.svg \
    camera-recorder:photo.svg \
    case-converter:text.svg \
    chmod-calculator:code.svg \
    chronometer:time.svg \
    docker-run-to-docker-compose-converter:docker.svg \
    email-normalizer:mail.svg \
    encryption:crypto.svg \
    eta-calculator:time.svg \
    git-memo:git.svg \
    hash-text:crypto.svg \
    html-entities:code.svg \
    http-status-codes:applications-internet.svg \
    iban-validator-and-parser:table.svg \
    integer-base-converter:accessories-calculator.svg \
    json-diff:diff.svg \
    json-to-csv:table.svg \
    json-to-toml:braces.svg \
    json-to-yaml-converter:braces.svg \
    keycode-info:keyboard.svg \
    list-converter:table.svg \
    lorem-ipsum-generator:text.svg \
    mac-address-generator:network.svg \
    markdown-to-html:code.svg \
    meta-tag-generator:tag.svg \
    mime-types:file.svg \
    numeronym-generator:text.svg \
    otp-code-generator-and-validator:key.svg \
    password-strength-analyser:shield.svg \
    pdf-signature-checker:certificate.svg \
    percentage-calculator:accessories-calculator.svg \
    phone-parser-and-formatter:phone.svg \
    regex-memo:brackets.svg \
    regex-tester:brackets.svg \
    roman-numeral-converter:accessories-calculator.svg \
    safelink-decoder:unlock.svg \
    slugify-string:text.svg \
    temperature-converter:thermometer.svg \
    text-to-binary:brackets.svg \
    text-to-nato-alphabet:text.svg \
    text-to-unicode:text.svg \
    toml-to-json:braces.svg \
    toml-to-yaml:braces.svg \
    url-parser:link.svg \
    user-agent-parser:browser.svg \
    yaml-to-json-converter:braces.svg \
    yaml-to-toml:braces.svg

  for p in $pairs
  set -l route (string split : -- $p)[1]
    set -l icon (string split : -- $p)[2]
    set -l dest "$ICONS_DIR/$route.svg"
    set -l srcfile "$src/$icon"
    if test -f $srcfile
      # Always (re)seed curated icons into icons/; never touch icons.d
      cp -f $srcfile $dest
    end
  end
end

seed_default_icons

# Build maps: dir->var and var->category from src/tools/index.ts using Node
set -l MAP_DIR2VAR "$CFG_DIR/dir_to_var.tsv"
set -l MAP_VAR2CAT "$CFG_DIR/var_to_cat.tsv"
log "Generating category maps from src/tools/index.ts"
node scripts/generate-it-tools-maps.mjs $MAP_DIR2VAR $MAP_VAR2CAT
if test $status -ne 0
  echo "Warning: failed to generate category maps; category icons may be generic" >&2
else
  log "Maps generated: $MAP_DIR2VAR, $MAP_VAR2CAT"
end

# Preload mapping files into memory to avoid subshell issues
set -g DIR2VAR_LINES (cat $MAP_DIR2VAR 2>/dev/null)
set -g VAR2CAT_LINES (cat $MAP_VAR2CAT 2>/dev/null)
set -l MAP_DIR2PATH "$CFG_DIR/dir_to_path.tsv"
node scripts/generate-it-tools-maps.mjs $MAP_DIR2VAR $MAP_VAR2CAT $MAP_DIR2PATH >/dev/null 2>&1
set -g DIR2PATH_LINES (cat $MAP_DIR2PATH 2>/dev/null)

function category_of_route
  set -l route $argv[1]
  if test -z "$route"
    echo ""
    return
  end
  set -l var ""
  for l in $DIR2VAR_LINES
    if test -z "$l"
      continue
    end
    set -l parts (string split \t -- $l)
    if test (count $parts) -lt 2
      continue
    end
    if test $parts[1] = $route
      set var $parts[2]
      break
    end
  end
  if test -z "$var"
    echo ""
    return
  end
  for l in $VAR2CAT_LINES
    if test -z "$l"
      continue
    end
    set -l parts (string split \t -- $l)
    if test (count $parts) -lt 2
      continue
    end
    if test $parts[1] = $var
      echo $parts[2]
      return
    end
  end
  echo ""
end

function route_path_for_dir
  set -l dir $argv[1]
  for l in $DIR2PATH_LINES
    set -l parts (string split \t -- $l)
    if test (count $parts) -ge 2
      if test $parts[1] = $dir
        echo $parts[2]
        return
      end
    end
  end
  echo "/$dir"
end

function icon_name_for_category
  switch $argv[1]
    case Crypto
      echo security-high
    case Converter
      echo applications-utilities
    case Web
      echo applications-internet
    case 'Images and videos'
      echo multimedia-photo-viewer
    case Development
      echo applications-development
    case Network
      echo network-workgroup
    case Math
      echo accessories-calculator
    case Measurement
      echo applications-science
    case Text
      echo accessories-text-editor
    case Data
      echo database
    case '*'
      echo applications-utilities
  end
end

# Try to resolve a per-tool custom icon file, else return empty
function find_tool_custom_icon
  set -l route $argv[1]
  # Prefer drop-in overrides
  for ext in svg png xpm ico
    set -l candidate "$CFG_DIR/icons.d/$route.$ext"
    if test -f $candidate
      echo $candidate
      return
    end
  end
  # Then seeded icons
  for ext in svg png xpm ico
    set -l candidate2 "$CFG_DIR/icons/$route.$ext"
    if test -f $candidate2
      echo $candidate2
      return
    end
  end
  echo ""
end

# Heuristic theme icon per tool route; returns either file path (if custom) or theme name
function tool_icon_for_route
  set -l route $argv[1]
  set -l custom (find_tool_custom_icon $route)
  if test -n "$custom"
    echo $custom
    return
  end

  set -l r $route
  set -l name ""
  if string match -qi "*token*" -- $r
    set name dialog-password
  else if string match -qi "*bcrypt*|*hash*|*hmac*|*encrypt*|*rsa*|*otp*|*jwt*" -- $r
    set name document-encrypt
  else if string match -qi "*uuid*|*ulid*|*random*|*shuffle*" -- $r
    set name media-playlist-shuffle
  else if string match -qi "*qr*|*barcode*" -- $r
    set name accessories-scanner
  else if string match -qi "*wifi*" -- $r
    set name network-wireless
  else if string match -qi "*ipv*|*network*|*mac-address*|*port*|*subnet*" -- $r
    set name network-workgroup
  else if string match -qi "*url*|*http*|*web*|*user-agent*" -- $r
    set name applications-internet
  else if string match -qi "*json*|*yaml*|*toml*|*xml*|*csv*|*viewer*|*formatter*|*minify*|*diff*|*jwt*" -- $r
    set name text-x-generic
  else if string match -qi "*sql*" -- $r
    set name text-x-generic
  else if string match -qi "*text*|*string*|*slugify*|*emoji*|*markdown*" -- $r
    set name accessories-text-editor
  else if string match -qi "*color*|*image*|*svg*|*camera*|*photo*|*placeholder*" -- $r
    set name multimedia-photo-viewer
  else if string match -qi "*date*|*time*|*chronometer*|*eta*|*benchmark*" -- $r
    set name preferences-system-time
  else if string match -qi "*math*|*percentage*|*converter*|*temperature*|*calculator*|*roman*|*base-converter*" -- $r
    set name accessories-calculator
  else if string match -qi "*git*|*docker*|*chmod*|*editor*|*wysiwyg*" -- $r
    set name applications-development
  else if string match -qi "*iban*|*phone*|*mime*|*meta*|*keycode*" -- $r
    set name preferences-system
  else
    set name (icon_name_for_category (category_of_route $r))
  end
  echo $name
end

# Rasterize SVG to PNG for rofi if possible
function maybe_rasterize_icon
  set -l path $argv[1]
  if test -z "$path"
    echo ""
    return
  end
  if string match -q "*.svg" -- $path
    if command -v rsvg-convert >/dev/null 2>&1
      set -l base (basename $path .svg)
      set -l out "$CFG_DIR/icons.cache/$base.png"
      rsvg-convert -w 96 -h 96 -o $out $path >/dev/null 2>&1; and echo $out; and return
    end
  end
  echo $path
end

function desktop_categories_for_category
  switch $argv[1]
    case Crypto
      echo 'Security;Utility;'
    case Converter
      echo 'Utility;'
    case Web
      echo 'Network;Utility;'
    case 'Images and videos'
      echo 'Graphics;AudioVideo;'
    case Development
      echo 'Development;'
    case Network
      echo 'Network;'
    case Math
      echo 'Science;'
    case Measurement
      echo 'Science;Utility;'
    case Text
      echo 'Utility;Office;'
    case Data
      echo 'Utility;'
    case '*'
      echo 'Utility;'
  end
end

# Build a TSV of (route \t Pretty Name)
set -l TSV "$CFG_DIR/tools.tsv"
echo -n > $TSV
set -l TSV_ROFI "$CFG_DIR/tools_rofi.tsv"  # route \t Pretty Name \t icon-name
echo -n > $TSV_ROFI
log "Scanning tools under: $TOOLS_DIR"

function pretty_name
  set s (string replace -a '-' ' ' -- $argv[1])
  # Title-case each word
  set words (string split ' ' -- $s)
  set out ""
  for w in $words
    set cap (string upper (string sub -s 1 -l 1 -- $w))(string sub -s 2 -- $w)
    set out "$out $cap"
  end
  echo (string trim -- $out)
end

# Enumerate tool routes from directories in src/tools/*
for path in (find $TOOLS_DIR -mindepth 1 -maxdepth 1 -type d | sort)
  set route (basename $path)

  # Skip any non-tool directories if present
  switch $route
    case ".git" "shared" "_*"
      continue
  end

  set nice (pretty_name $route)
  printf "%s\t%s\n" "$route" "$nice" >> $TSV
end

set -l TOOL_COUNT (wc -l < $TSV | string trim)
log "Discovered $TOOL_COUNT tools"

# Generate the rofi script mode (write file directly in fish)
set -l ROFI_SCRIPT "$BIN_DIR/rofi-it-tools"
log "Writing rofi script: $ROFI_SCRIPT"
begin
  echo "#!/usr/bin/env bash"
  echo "set -euo pipefail"
  echo
  echo "# Rofi script mode for it-tools. Reads ~/.config/it-tools/tools.tsv"
  echo "TSV=\"\$HOME/.config/it-tools/tools.tsv\""
  echo "TSV_ROFI=\"\$HOME/.config/it-tools/tools_rofi.tsv\""
  echo "BASE_URL=\"$BASE_URL\""
  echo "BROWSER_TEMPLATE=\"$BROWSER_CMDLINE\""
  echo "PREFIX=\"$PREFIX\""
  echo
  echo 'retv="${ROFI_RETV:-0}"'
  echo 'if [ "$retv" -eq 0 ]; then'
  echo '  # Initial list shown by rofi (with icons if available)'
  echo '  if [ -f "$TSV_ROFI" ]; then'
  echo '    while IFS=$'"'\t'"' read -r route nice icon; do'
  echo '      [ -z "$route" ] && continue'
  echo '      printf '\''%s\0icon\x1f%s\n'\'' "$nice" "$icon"'
  echo '    done < "$TSV_ROFI"'
  echo '  elif [ -f "$TSV" ]; then'
  echo '    while IFS=$'"'\t'"' read -r route nice; do'
  echo '      [ -z "$route" ] && continue'
  echo '      printf '\''%s\n'\'' "$nice"'
  echo '    done < "$TSV"'
  echo '  fi'
  echo '  exit 0'
  echo 'fi'
  echo
  echo 'sel="${1:-}"'
  echo '[ -z "$sel" ] && sel="$(cat)"'
  echo '[ -z "$sel" ] && exit 0'
  echo 'route=""'
  echo 'if [ -f "$TSV_ROFI" ]; then'
  echo '  while IFS=$'"'\t'"' read -r r n i; do'
  echo '    if [ "$n" = "$sel" ]; then route="$r"; break; fi'
  echo '  done < "$TSV_ROFI"'
  echo 'elif [ -f "$TSV" ]; then'
  echo '  while IFS=$'"'\t'"' read -r r n; do'
  echo '    if [ "$n" = "$sel" ]; then route="$r"; break; fi'
  echo '  done < "$TSV"'
  echo 'fi'
  echo '[ -z "$route" ] && exit 0'
  echo 'route="${route#/}"  # strip any leading slash to avoid //'
  echo 'url="$BASE_URL/$route?embed=1"'
  echo 'cmd="${PREFIX}${BROWSER_TEMPLATE//%URL%/$url}"'
  echo 'nohup bash -c "$cmd" >/dev/null 2>&1 &'
end > $ROFI_SCRIPT
chmod +x "$ROFI_SCRIPT"

# Convenience launcher to open rofi directly in the tools mode with icons
set -l ROFI_TOOLS_MENU "$BIN_DIR/rofi-tools-menu"
log "Writing convenience launcher: $ROFI_TOOLS_MENU"
begin
  echo "#!/usr/bin/env bash"
  echo "exec rofi -show-icons -modi \"drun,$MODI_LABEL:$ROFI_SCRIPT\" -show $MODI_LABEL"
end > $ROFI_TOOLS_MENU
chmod +x "$ROFI_TOOLS_MENU"

# Create one .desktop per tool
log "Creating desktop entries for $TOOL_COUNT tools"
set -l CREATED 0
set -l LINES (string split "\n" -- (cat $TSV))
log "TSV lines loaded: "(count $LINES)
if test (count $LINES) -gt 0
  log "First TSV line: "$LINES[1]
end
for line in $LINES
  if test -z "$line"
    continue
  end
  set route (string split \t -- $line)[1]
  set nice  (string split \t -- $line)[2]
  set -l route_path (route_path_for_dir $route)
  set url "$BASE_URL$route_path?embed=1"
  set desktop "$APPS_DIR/tools-$route.desktop"
  set cat (category_of_route $route)
  set tool_icon (tool_icon_for_route $route)
  log "Processing: $route -> $desktop"

  # Compose Exec
  set execcmd "$PREFIX$BROWSER_CMDLINE"
  set execcmd (string replace "%URL%" $url -- $execcmd)

  # Write desktop file (fish-friendly)
  begin
    echo "[Desktop Entry]"
    echo "Type=Application"
    echo "Name=Tools: $nice"
    echo "Comment=IT-Tools — $nice"
    echo "Exec=$execcmd"
    echo "NoDisplay=true"
    # Icon selection: prefer custom file, else theme icon per category
    if test -f $ICON_PATH
      echo "Icon=$ICON_PATH"
    else
      echo "Icon=$tool_icon"
    end
    set -l cats (desktop_categories_for_category $cat)
    if test -n "$cats"
      echo "Categories=$cats"
    else
      echo "Categories=Utility;"
    end
    echo "Keywords=tools;it-tools;$route;$nice;"
    echo "Terminal=false"
  end > $desktop
  # Append to rofi TSV: route, name, icon (prefer rasterized path for rofi)
  set -l rofi_icon (maybe_rasterize_icon $tool_icon)
  printf "%s\t%s\t%s\n" "$route_path" "$nice" "$rofi_icon" >> $TSV_ROFI
  set CREATED (math $CREATED + 1)
  set -l rem (math "$CREATED % 10")
  if test $rem -eq 0
    log "...created $CREATED / $TOOL_COUNT entries"
  end
end

# Add a desktop that opens the rofi mode directly
set -l MENU_DESK "$APPS_DIR/tools-menu.desktop"
begin
  echo "[Desktop Entry]"
  echo "Type=Application"
  echo "Name=Tools: Menu"
  echo "Comment=Browse and launch IT-Tools"
  echo "Exec=rofi -show-icons -modi \"drun,$MODI_LABEL:$ROFI_SCRIPT\" -show $MODI_LABEL"
  if test -f $ICON_PATH
    echo "Icon=$ICON_PATH"
  else
    echo "Icon=applications-utilities"
  end
  echo "Terminal=false"
  echo "Categories=Utility;Development;"
end > $MENU_DESK
log "Wrote menu desktop: $MENU_DESK"

# Update desktop DB (best-effort)
if command -v update-desktop-database >/dev/null 2>&1
  log "Updating desktop database"
  update-desktop-database $APPS_DIR >/dev/null 2>&1
else
  log "'update-desktop-database' not found; skipping refresh"
end

log "Done. Created $CREATED desktop entries"
echo "• Rofi mode: rofi -modi \"drun,tools:$ROFI_SCRIPT\" -show tools"
echo "• Or open 'Tools: Menu' from rofi drun"
echo "• Per-tool entries created under $APPS_DIR (search 'Tools: ...')"
