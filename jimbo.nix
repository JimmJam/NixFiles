{ config, pkgs, options, ... }:
let
  # Define colors used by almost all programs
  colorVar = ''purple'';
  colorVals =
    if colorVar == ''purple'' then {
      primecol = ''8800FF''; #8800FF
      accentcol = ''3b2460''; #3b2460
      splitcol = ''69507f''; #69507f
      actsplitcol = ''cd97fc''; #cd97fc
      darkcol = ''202020''; #202020
      midcol = ''282828''; #282828
      foldercol = ''violet'';
      themetweak = ''dracula'';
      theme = ''Colloid-Purple-Dark-Dracula'';
      wallpaper1 = ''https://i.imgur.com/xu3a237.png'';
      wallpaper2 = ''https://i.imgur.com/coAKg4r.png'';
      wallpaper3 = ''https://i.imgur.com/xu3a237.png'';
    }
    else {
      primecol = ''3823c4''; #3823c4
      accentcol = ''1b1f59''; #1b1f59
      splitcol = ''555b9e''; #555b9e
      actsplitcol = ''5980b7''; #5980b7
      darkcol = ''101419''; #101419
      midcol = ''171c23''; #171c23
      foldercol = ''indigo'';
      themetweak = ''black'';
      theme = ''Colloid-Purple-Dark'';
      wallpaper1 = ''https://i.imgur.com/Wy3eIjS.png'';
      wallpaper2 = ''https://i.imgur.com/6MdUKCW.png'';
      wallpaper3 = ''https://i.imgur.com/6dCHfXP.png'';
    };
  primecol = colorVals.primecol;
  accentcol = colorVals.accentcol;
  splitcol = colorVals.splitcol;
  actsplitcol = colorVals.actsplitcol;
  darkcol = colorVals.darkcol;
  midcol = colorVals.midcol;
  foldercol = colorVals.foldercol;
  themetweak = colorVals.themetweak;
  theme = colorVals.theme;
  urgentcol = ''9e3c3c''; #9e3c3c
  textcolor = ''C7D3E3''; #C7D3E3

  # Theme stuff
  draculacheck = str:
    if str == "dracula" then
      "-Dracula"
    else
      "";

  # Define paths used by different programs
  swaycfg = ''~/.config/sway'';
  swayscripts = ''${swaycfg}/scripts'';
  waybarcfg = ''${swaycfg}/waybar'';

  # Define the primary monitor
  monitor1 = ''HDMI-A-1'';
  monitor2 = ''DP-1'';
  monitor3 = ''DP-2'';

  # Define program arguments called repeatedly
  bmen = ''bemenu --fn "Ubuntu 13" --nb "#${darkcol}" --ab "#${darkcol}" --tb "#${primecol}" --fb "#${darkcol}" --tf "#FFFFFF" --hf "#FFFFFF" --hb "#${primecol}" -f --ignorecase --hp 8 -p'';

  # Main Sway config that just sources other files
  swayconfig = ''
    # Source other files for organization

    # Autostart programs
    exec ${swaycfg}/programs
    
    # Define monitors and mice
    include ${swaycfg}/hardware
    
    # Assign workspaces to monitors
    include ${swaycfg}/workspaces
    
    # Define theming rules
    include ${swaycfg}/theme
    
    # Define all keybindings
    include ${swaycfg}/hotkeys
    
    # Define all window rules
    include ${swaycfg}/rules
  '';

  # Define which programs autostart with Sway
  swayprograms = ''
    #!/usr/bin/env bash

    # Scratchpads
    kitty --class=gotop -o font_size=14 gotop &
    kitty --class=music -o font_size=14 ranger &
    pavucontrol &
    easyeffects &
    
    # Start daemons and tray apps
    pkill -f alarms.sh; ${swayscripts}/alarms.sh --alarms &
    wl-paste -t text --watch clipman store &
    wl-copy &
    mako &
    blueman-applet &
    sunshine &
    
    # Start polkit agent
    ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1 &
    
    # Start foreground apps
    ${waybarcfg}/start.sh &
    librewolf -P Variety --name=Variety &
    kittydash &
    
    # Change to workspace 1
    swaymsg workspace 1:1
  '';

  # Define how Sway treats monitors and mice
  swayhardware = ''
    # Define wallpaper folder for ultrawide
    set $wide Downloaded
    
    # Define displays
    output ${monitor1} {
      pos 1920 405 mode 1920x1080@119.982Hz
      max_render_time 3
      bg "$HOME/Pictures/Wallpapers/Split/$wide/1.png" fill
      adaptive_sync on
    }
    
    output ${monitor2} {
      pos 0 405 mode 1920x1080@75.001Hz
      max_render_time 3
      bg "$HOME/Pictures/Wallpapers/Split/$wide/2.png" fill
    }
    
    output ${monitor3} {
      pos 3840 0 mode 1680x1050@59.883Hz transform 270
      max_render_time 3
      bg "$HOME/Pictures/Wallpapers/Split/$wide/3.png" fill
    }
    
    # Define cursor rules
    input 9610:4103:SINOWEALTH_Game_Mouse {
      accel_profile "flat"
      pointer_accel -0.4
    }
    
    # Define cursor rules
    input 9639:64097:Compx_2.4G_Receiver_Mouse {
      accel_profile "flat"
      pointer_accel -0.4
    }
  '';

  # Define which monitors get which workspaces
  swayworkspaces = ''
    # Define workspace names as variables
    set $ws0 0:0
    set $ws1 1:1
    set $ws2 2:2
    set $ws3 3:3
    set $ws1+ 11:I
    set $ws2+ 22:II
    set $ws3+ 33:III
    
    set $ws4 4:4
    set $ws5 5:5
    set $ws6 6:6
    set $ws4+ 44:IV
    set $ws5+ 55:V
    set $ws6+ 66:VI
    
    set $ws7 7:7
    set $ws8 8:8
    set $ws9 9:9
    set $ws7+ 77:VII
    set $ws8+ 88:VIII
    set $ws9+ 99:IX
    
    # Put the workspaces where they need to be
    workspace $ws0 output ${monitor1}
    workspace $ws1 output ${monitor1}
    workspace $ws2 output ${monitor1}
    workspace $ws3 output ${monitor1}
    workspace $ws1+ output ${monitor1}
    workspace $ws2+ output ${monitor1}
    workspace $ws3+ output ${monitor1}
    
    workspace $ws4 output ${monitor2}
    workspace $ws5 output ${monitor2}
    workspace $ws6 output ${monitor2}
    workspace $ws4+ output ${monitor2}
    workspace $ws5+ output ${monitor2}
    workspace $ws6+ output ${monitor2}
    
    workspace $ws7 output ${monitor3}
    workspace $ws8 output ${monitor3}
    workspace $ws9 output ${monitor3}
    workspace $ws7+ output ${monitor3}
    workspace $ws8+ output ${monitor3}
    workspace $ws9+ output ${monitor3}
  '';

  # Define Sway's theming rules
  swaytheme = ''
    # Font for window titles.
    font pango:Ubuntu 9
    
    # Borders, gaps, titlebars, behavior
    default_border pixel 3
    default_floating_border pixel 3
    gaps inner 5
    titlebar_padding 5 1
    
    # Smart things
    smart_gaps on
    hide_edge_borders --i3 smart
    
    # SwayFX eyecandy
    blur enable
    blur_passes 3
    blur_radius 5
    
    # Set transparency rules
    layer_effects 'rofi' blur enable
    layer_effects 'notifications' blur enable; blur_ignore_transparent enable
    
    client.focused          #${primecol} #${primecol} #${textcolor} #${actsplitcol} #${primecol}
    client.focused_inactive #${accentcol} #${accentcol} #${textcolor} #${splitcol} #${accentcol}
    client.unfocused        #${darkcol} #${darkcol} #${textcolor} #${splitcol} #${splitcol}
    client.urgent           #${urgentcol} #${urgentcol} #${textcolor} #${urgentcol} #${urgentcol}
  '';

  # Define all the hotkeys I use on Sway
  swayhotkeys = ''
    #################
    # Launcher Keys #
    #################
    
    # Firefox Personal/School
    bindsym Mod4+F1 exec librewolf -P Jimbo --name=JimboBrowser --no-remote | notify-send "Librewolf Main" --expire-time=1500
    bindsym Mod4+F2 exec librewolf -P School --name=SchoolBrowser --no-remote | notify-send "Librewolf School" --expire-time=1500
    bindsym Mod4+F3 exec librewolf -P Variety --name=Variety --no-remote | notify-send "Librewolf Variety" --expire-time=1500
    
    # VM Looking Glass
    bindsym Mod4+F4 exec looking-glass-client -p 5950 input:rawMouse=yes | notify-send "Looking Glass" --expire-time=1500
    
    # Game tools
    bindsym Mod4+F5 exec steam | notify-send "Steam" --expire-time=1500
    bindsym Mod4+F6 exec kitty --class=Hiddenlol heroic | notify-send "Heroic Games" --expire-time=1500
    bindsym Mod4+F7 exec ${swayscripts}/bescripts.sh --games | notify-send "Games" --expire-time=1500
    
    # Production tools
    bindsym Mod4+F9 exec ${swayscripts}/bescripts.sh --production | notify-send "Production" --expire-time=1500
    
    # Virt-Manager
    bindsym Mod4+F10 exec virt-manager | notify-send "Virtual Machines" --expire-time=1500
    
    # Config Files and Scratchpads
    bindsym Mod4+F12 exec ${swayscripts}/bescripts.sh --config | notify-send "Configs" --expire-time=1500
    bindsym Mod4+Ctrl+F12 exec ${swayscripts}/bescripts.sh --scratchpads | notify-send "Scratchpads" --expire-time=1500
    
    # Alacritty, dmenu, clipmenu, media script, power menu, show/hide polybar
    bindsym Mod4+Return exec kitty
    bindsym Mod4+s exec bemenu-run --fn "Ubuntu 13" --nb "#${darkcol}" --ab "#${darkcol}" --tb "#${primecol}" --fb "#${darkcol}" --tf "#ffffff" --hf "#ffffff" --hb "#${primecol}" --hp 8 --ignorecase -p "Run:"
    bindsym Mod4+c exec clipman pick -t rofi -T'-font "Ubuntu 13"'
    bindsym Mod4+y exec ${swayscripts}/bescripts.sh --media
    bindsym Mod4+x exec ${swayscripts}/bescripts.sh --power
    bindsym Mod4+b exec pkill -USR1 waybar
    bindsym Mod4+Escape exec ${swayscripts}/wtools.sh --kill
    
    # Restart Polybar, Thunar, Emoji Picker, Ranger, Rofi Launcher, Save Replay
    bindsym Mod4+Shift+p exec notify-send "Restart Waybar" --expire-time=1500 && ${waybarcfg}/start.sh
    bindsym Mod4+Shift+t exec pcmanfm-qt
    bindsym Mod4+Shift+e exec BEMOJI_PICKER_CMD="eval rofi -font 'Ubuntu 13' -dmenu -p Emoji" bemoji -n -P 0
    bindsym Mod4+Shift+Return exec kitty -o font_size=14 ranger
    bindsym Mod4+Shift+s exec rofi -show drun -drun-display-format {name} -show-icons -modi drun -font "Ubuntu 14"
    
    # Rofi fuzzy finder, wprop, colorpicker
    bindsym Mod4+Mod1+Ctrl+Return exec xdg-open $(locate / | rofi -threads 0 -width 100 -dmenu -i -font "Ubuntu 13" -p "locate")
    bindsym Mod4+Ctrl+x exec ${swayscripts}/wtools.sh --prop
    bindsym Mod4+Ctrl+c exec grim -g "$(slurp -b 00000000 -p; sleep 1)" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | sed -n '2p' | awk '{print $3}' | wl-copy -n && notify-send "Color copied to clipboard" --expire-time=1500
    
    ##############
    # Media Keys #
    ##############
    
    # Raise/lower volume
    bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    
    # Raise/Lower mpv volume
    bindsym Mod1+XF86AudioRaiseVolume exec playerctl --player=mpv volume 0.05+
    bindsym Mod1+XF86AudioLowerVolume exec playerctl --player=mpv volume 0.05-
    
    # Mute, Stop
    bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindsym XF86AudioStop exec playerctl --player=mpv stop
    
    # Play MPV or Firefox
    bindsym XF86AudioPlay exec playerctl --player=firefox play-pause
    bindsym Mod1+XF86AudioPlay exec playerctl --player=mpv play-pause
    
    # Next/Previous
    bindsym XF86AudioNext exec playerctl --player=firefox next
    bindsym XF86AudioPrev exec playerctl --player=firefox previous
    bindsym Mod1+XF86AudioNext exec playerctl --player=mpv next
    bindsym Mod1+XF86AudioPrev exec playerctl --player=mpv previous
    
    #####################
    # Notification keys #
    #####################
    
    # Toggle dunst
    bindsym Mod4+n exec ${swayscripts}/notif-toggle.sh
    bindsym Mod4+Shift+n exec makoctl restore
    bindsym Mod4+Ctrl+n exec makoctl dismiss -a
    
    ######################
    # Miscellaneous keys #
    ######################
    
    # Screenshot
    bindsym Print exec ${swayscripts}/screenshots.sh --swappy
    bindsym Mod4+Shift+f exec ${swayscripts}/screenshots.sh --swappy
    bindsym Alt+Print exec ${swayscripts}/screenshots.sh --copy
    bindsym Shift+Print exec ${swayscripts}/screenshots.sh --current
    bindsym Ctrl+Print exec ${swayscripts}/screenshots.sh --all
    
    # Resolution stuff
    bindsym Ctrl+Mod1+r exec wdisplays
    bindsym Ctrl+Mod4+Mod1+r exec ${swayscripts}/bescripts.sh --resolutions
    
    # Server SSH
    bindsym Mod4+Ctrl+Return exec kitty kitten ssh 192.168.1.17
    
    # Open clipboard video in mpv
    bindsym Mod4+Ctrl+y exec mpv --loop-playlist=no --keep-open=yes $(wl-paste) | notify-send "Playing in MPV" --expire-time=1500
    
    # Display Brightness and Keyboard Brightness
    bindsym XF86MonBrightnessUp exec ${pkgs.light}/bin/light -A 5
    bindsym XF86MonBrightnessDown exec ${pkgs.light}/bin/light -U 5
    bindsym XF86KbdBrightnessUp exec ${pkgs.light}/bin/light -s sysfs/leds/smc::kbd_backlight -A 5
    bindsym XF86KbdBrightnessDown exec ${pkgs.light}/bin/light -s sysfs/leds/smc::kbd_backlight -U 5
    
    #############
    # Sway keys #
    #############
    
    # Allow for window moving
    floating_modifier Mod4
    
    # Kill focused window, reload config
    bindsym Mod4+q kill
    bindsym Mod4+Shift+r reload
    
    # Switch to workspace
    bindsym Mod4+grave workspace $ws0
    bindsym Mod4+1 workspace $ws1
    bindsym Mod4+2 workspace $ws2
    bindsym Mod4+3 workspace $ws3
    bindsym Mod4+4 workspace $ws4
    bindsym Mod4+5 workspace $ws5
    bindsym Mod4+6 workspace $ws6
    bindsym Mod4+7 workspace $ws7
    bindsym Mod4+8 workspace $ws8
    bindsym Mod4+9 workspace $ws9
    
    # Switch to workspace+
    bindsym Mod1+F1 workspace $ws1+
    bindsym Mod1+F2 workspace $ws2+
    bindsym Mod1+F3 workspace $ws3+
    bindsym Mod1+F4 workspace $ws4+
    bindsym Mod1+F5 workspace $ws5+
    bindsym Mod1+F6 workspace $ws6+
    bindsym Mod1+F7 workspace $ws7+
    bindsym Mod1+F8 workspace $ws8+
    bindsym Mod1+F9 workspace $ws9+
    
    # Move window to workspace, focus that workspace
    bindsym Mod4+Shift+grave move container to workspace $ws0; workspace $ws0
    bindsym Mod4+Shift+1 move container to workspace $ws1; workspace $ws1
    bindsym Mod4+Shift+2 move container to workspace $ws2; workspace $ws2
    bindsym Mod4+Shift+3 move container to workspace $ws3; workspace $ws3
    bindsym Mod4+Shift+4 move container to workspace $ws4; workspace $ws4
    bindsym Mod4+Shift+5 move container to workspace $ws5; workspace $ws5
    bindsym Mod4+Shift+6 move container to workspace $ws6; workspace $ws6
    bindsym Mod4+Shift+7 move container to workspace $ws7; workspace $ws7
    bindsym Mod4+Shift+8 move container to workspace $ws8; workspace $ws8
    bindsym Mod4+Shift+9 move container to workspace $ws9; workspace $ws9
    
    # Move window to workspace, focus that workspace+
    bindsym Mod1+Shift+F1 move container to workspace $ws1+; workspace $ws1+
    bindsym Mod1+Shift+F2 move container to workspace $ws2+; workspace $ws2+
    bindsym Mod1+Shift+F3 move container to workspace $ws3+; workspace $ws3+
    bindsym Mod1+Shift+F4 move container to workspace $ws4+; workspace $ws4+
    bindsym Mod1+Shift+F5 move container to workspace $ws5+; workspace $ws5+
    bindsym Mod1+Shift+F6 move container to workspace $ws6+; workspace $ws6+
    bindsym Mod1+Shift+F7 move container to workspace $ws7+; workspace $ws7+
    bindsym Mod1+Shift+F8 move container to workspace $ws8+; workspace $ws8+
    bindsym Mod1+Shift+F9 move container to workspace $ws9+; workspace $ws9+
    
    # Change focus across windows
    bindsym Mod4+Up focus up
    bindsym Mod4+Down focus down
    bindsym Mod4+Left focus left
    bindsym Mod4+Right focus right
    
    # Change focus across monitors
    bindsym Mod4+j focus output ${monitor2}
    bindsym Mod4+k focus output ${monitor1}
    bindsym Mod4+l focus output ${monitor3}
    
    # Move focused window
    bindsym Mod4+Shift+Up move up
    bindsym Mod4+Shift+Down move down
    bindsym Mod4+Shift+Left move left
    bindsym Mod4+Shift+Right move right
    
    # Move window across monitors
    bindsym Mod4+Shift+j move output ${monitor2}; focus output ${monitor2}
    bindsym Mod4+Shift+k move output ${monitor1}; focus output ${monitor1}
    bindsym Mod4+Shift+l move output ${monitor3}; focus output ${monitor3}
    
    # Change focus between floating/tiled, toggle floating
    bindsym Mod4+space focus mode_toggle
    bindsym Mod4+Shift+space floating toggle
    
    # Allow a window to be visible on all workspaces, toggle border
    bindsym Mod4+0 exec ${swayscripts}/pin-window.sh
    
    # Toggle fullscreen
    bindsym Mod4+f fullscreen toggle
    bindsym Mod4+Mod1+Ctrl+f fullscreen toggle global
    
    # Change container layout
    bindsym Mod4+w layout toggle split
    bindsym Mod4+e layout tabbed
    
    # Change split direction
    bindsym Mod4+h split h
    bindsym Mod4+v split v
    
    # Focus parent / child
    bindsym Mod4+a focus parent
    bindsym Mod4+d focus child
    
    # Resize windows
    bindsym Mod4+Mod1+Up resize grow height 5 px or 5 ppt
    bindsym Mod4+Mod1+Down resize shrink height 5 px or 5 ppt
    bindsym Mod4+Mod1+Left resize shrink width 5 px or 5 ppt
    bindsym Mod4+Mod1+Right resize grow width 5 px or 5 ppt
    
    # Adjust gap size
    bindsym Mod4+Shift+equal gaps inner current set 5
    bindsym Mod4+equal gaps inner current plus 5
    bindsym Mod4+minus gaps inner current minus 5
    
    # Scratchpads
    bindsym Ctrl+Shift+Escape [app_id="gotop"] scratchpad show, move position center
    bindsym Mod4+Shift+m [app_id="music"] scratchpad show, move position center
    bindsym Mod4+Mod1+Ctrl+End [app_id="replay"] scratchpad show, move position center
    bindsym Mod4+Shift+v [app_id="pavucontrol"] scratchpad show, move position center
    bindsym Mod4+Shift+Backslash [app_id="com.github.wwmm.easyeffects"] scratchpad show, move position center
  '';

  # Define how windows are treated and which workspace they go to
  swayrules = ''
    # Behavioral rules
    title_align center
    focus_on_window_activation focus
    
    # Scratchpads
    for_window [app_id="gotop"] floating enable, sticky enable, move scratchpad, resize set 1200 900
    for_window [app_id="music"] floating enable, sticky enable, move scratchpad, resize set 1000 650
    for_window [app_id="replay"] floating enable, sticky enable, move scratchpad, resize set 1000 650
    for_window [app_id="pavucontrol"] floating enable, sticky enable, move scratchpad, resize set 1000 800, opacity 0.9
    for_window [app_id="com.github.wwmm.easyeffects"] floating enable, sticky enable, move scratchpad, resize set 1000 800, opacity 0.9
    for_window [app_id="Hiddenlol"] move scratchpad
    
    # Give apps that don't have them borders
    for_window [app_id="com.github.wwmm.easyeffects"] border pixel 3
    for_window [class="steam"] border pixel 3
    for_window [app_id="gnome-disks"] border pixel 3
    for_window [app_id="swappy"] border pixel 3
    for_window [app_id="virt-manager"] border pixel 3
    for_window [window_role="pop-up"] border pixel 3
    
    # Disable auto-focus
    no_focus [app_id="looking-glass-client"]
    
    # Neither boders nor scratchpads
    for_window [app_id="smb"] floating enable
    for_window [app_id="cmst"] floating enable
    for_window [app_id="float"] floating enable
    for_window [app_id="looking-glass-client"] fullscreen enable
    for_window [title="^GlobalShot"] floating enable, fullscreen enable global
    
    # Assign apps to workspaces
    assign [app_id="smb"] $ws1
    assign [app_id="JimboBrowser"] $ws1
    assign [app_id="SchoolBrowser"] $ws1+
    assign [class="steam"] $ws2
    assign [class="heroic"] $ws2
    assign [app_id="looking-glass-client"] $ws2+
    assign [app_id="com.obsproject.Studio"] $ws4+
    assign [app_id="serverdash"] $ws4
    assign [app_id="Variety"] $ws7
    assign [class="zoom"] $ws6+
  '';

  # Sway's start script with necessary variables, used by greetd
  swaystart = ''
    #!/usr/bin/env bash

    # Use NVIDIA variables if drivers are in use
    if lspci -k | grep "Kernel driver in use: nvidia" &> /dev/null; then
      # NVIDIA/AMD variables
      export LIBVA_DRIVER_NAME=nvidia
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1
    else
      :
    fi
    
    # Sway/Wayland
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_DESKTOP=sway
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=gtk2
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    
    # OpenGL Variables
    export __GL_GSYNC_ALLOWED=0
    export __GL_VRR_ALLOWED=0

    # Start Sway
    dbus-run-session sway --unsupported-gpu
  '';

  # Swappy config, for screenshot editing
  swappyconfig = ''
    [Default]
    early_exit=true
    save_dir=$HOME/Pictures/Screenshots
  '';

  # All my bemenu scripts in one file
  bescripts = ''
    #!/usr/bin/env bash
    
    # configs function
    handle_configs() {
      configs=$(echo -e "sway\nhotkeys\nrules\ntheming\nhardware\nworkspaces\nstart\nprograms\nwaybar\nwaybar-style\nranger\nalarms\nscreenshots\nkitty\nrofi\nfull-update\ncleanup\nfolder\nzshrc\nbescripts" | ${bmen} configs)
      case $configs in
        sway) kitty -o font_size=14 nvim ${swaycfg}/config ;;
        hotkeys) kitty -o font_size=14 nvim ${swaycfg}/hotkeys ;;
        rules) kitty -o font_size=14 nvim ${swaycfg}/rules ;;
        theming) kitty -o font_size=14 nvim ${swaycfg}/theme ;;
        hardware) kitty -o font_size=14 nvim ${swaycfg}/hardware ;;
        workspaces) kitty -o font_size=14 nvim ${swaycfg}/workspace ;;
        start) kitty -o font_size=14 nvim ${swaycfg}/start.sh ;;
        programs) kitty -o font_size=14 nvim ${swaycfg}/programs ;;
        waybar) kitty -o font_size=14 nvim ${swaycfg}/waybar/config ;;
        waybar-style) kitty -o font_size=14 nvim ${swaycfg}/waybar/style.css ;;
        ranger) kitty -o font_size=14 nvim ~/.config/ranger/rifle.conf ;;
        alarms) kitty -o font_size=14 nvim ${swayscripts}/alarms.sh ;;
        screenshots) kitty -o font_size=14 nvim ${swayscripts}/screenshots.sh ;;
        kitty) kitty -o font_size=14 nvim ~/.config/kitty/kitty.conf ;;
        rofi) kitty -o font_size=14 nvim ~/.config/rofi/purple.rasi ;;
        full-update) kitty -o font_size=14 nvim ${swayscripts}/tools/full-update.sh ;;
        cleanup) kitty -o font_size=14 nvim ${swayscripts}/tools/cleanup.sh ;;
        folder) kitty -o font_size=14 ranger ${swaycfg}/ ;;
        zshrc) kitty -o font_size=14 nvim ~/.zshrc ;;
        bescripts)  kitty -o font_size=14 nvim ${swayscripts}/bescripts.sh ;;
      esac
    }
    
    # Scratchpad function
    handle_scratchpads() {
      SCRATCHPADS=$(echo -e "Gotop\nMusic\nPavuControl\nEasyEffects" | ${bmen} Scratchpads)
      case $SCRATCHPADS in
        Gotop) kitty --class=gotop -o font_size=14 gotop ;;
        Music) kitty --class=music -o font_size=14 ranger ;;
        PavuControl) pavucontrol ;;
        EasyEffects) easyeffects ;;
      esac
    }
    
    # Lock menu
    handle_power() {
      POWER=$(echo -e "Shutdown\nReboot\nSleep\nLock\nKill" | ${bmen} Power)
      case $POWER in
        Shutdown) shutdown now ;;
        Reboot) reboot ;;
        Sleep) ${swayscripts}/lock.sh --sleep & ;;
        Lock) ${swayscripts}/lock.sh & ;;
        Kill) pkill -9 sway ;;
      esac
    }
    
    # Games launcher
    handle_games() {
      GAMES=$(echo -e "Prism\nBedrock\nMineOnline\nMineTest\nVeloren\nRuneLite" | ${bmen} Games)
      case $GAMES in
        Prism) prismlauncher ;;
        MineTest) minetest ;;
        Veloren) airshipper run ;;
        RuneLite) runelite
      esac
    }
    
    # Media launcher
    handle_media() {
      RET=$(echo -e "YouTube\nMusic\nHistory\nAnime" | ${bmen} Media)
      case $RET in
        YouTube) ytfzf -D ;;
        Music ) ytfzf -D -m ;;
        History) kitty ytfzf -H ;;
        Anime) kitty ani-cli -q 720 ;;
      esac
    }
    
    # Production tools
    handle_production() {
      PRODUCTION=$(echo -e "OBS\nKrita\nKdenlive\nAudacity" | ${bmen} Production)
      case $PRODUCTION in
        OBS) obs ;;
        Krita) krita;;
        Kdenlive) kdenlive ;;
        Audacity) audacity ;;
      esac
    }
    
    # Resolutions
    handle_resolutions() {
      RET=$(echo -e "Default\nWide\nGPU2" | ${bmen} Resolution)
      case $RET in
        Default) swaymsg reload ;;
        Wide) swaymsg "output HDMI-A-1 enable pos 1680 0 mode 1680x1050@59.954Hz
        	output DP-3 enable pos 3360 0 transform 0
        	output DP-2 enable pos 0 0 mode 1680x1050@59.954Hz" ;;
        GPU2) swaymsg "output HDMI-A-1 enable pos 1680 110 mode 1920x1080@60Hz
        	output DP-1 enable pos 0 0 transform 0" ;;
      esac
    }
    
    # Check for command-line arguments
    if [ "$1" == "--config" ]; then
      handle_configs
    elif [ "$1" == "--scratchpads" ]; then
      handle_scratchpads
    elif [ "$1" == "--power" ]; then
      handle_power
    elif [ "$1" == "--games" ]; then
      handle_games
    elif [ "$1" == "--media" ]; then
      handle_media
    elif [ "$1" == "--production" ]; then
      handle_production
    elif [ "$1" == "--resolutions" ]; then
      handle_resolutions
    else
      echo "Please use a valid argument."
    fi
  '';

  # Swaylock's colors and background image
  lockscript = ''
    #!/usr/bin/env bash

    # Set the lock script
    lockscript() {
      BLANK='#00000000'
      CLEAR='#FFFFFF22'
      DEFAULT='#${primecol}FF'
      TEXT='#FFFFFFFF'
      WRONG='#680082FF'
      VERIFYING='#${accentcol}FF'
      
      swaylock -f -e \
      --key-hl-color=$VERIFYING \
      --bs-hl-color=$WRONG \
      \
      --ring-clear-color=$CLEAR \
      --ring-ver-color=$VERIFYING \
      --ring-wrong-color=$WRONG \
      --ring-color=$DEFAULT \
      --ring-clear-color=$VERIFYING \
      \
      --inside-color=$CLEAR \
      --inside-ver-color=$CLEAR \
      --inside-wrong-color=$CLEAR \
      --inside-clear-color=$CLEAR \
      \
      --text-color=$TEXT \
      --text-clear-color=$TEXT \
      --text-ver-color=$TEXT \
      --text-caps-lock-color=$TEXT \
      --text-wrong-color=$TEXT \
      \
      --indicator \
      --indicator-radius=80 \
      --image=~/Pictures/Wallpapers/VMs\ Wallpaper.png \
      --clock \
      --font=Ubuntu \
      --font-size=30 \
      --timestr="%I:%M%p" \
      --datestr="%a %b %d %Y"
    }
    
    # Handle whether to lock or sleep
    if [ "$1" == "--sleep" ]; then
      lockscript &
      exec swayidle -w \
      timeout 1 'swaymsg "output * dpms off"' \
      resume 'swaymsg "output * dpms on"; pkill -9 swayidle'
    else
      lockscript
    fi
  '';

  # Toggle notifications using mako
  notif-toggle = ''
    #!/usr/bin/env bash

    # Run makoctl mode and store the output in a variable
    mode_output=$(makoctl mode)
    
    # Extract the second line after "default"
    mode_line=$(echo "$mode_output" | sed -n '/default/{n;p}')
    
    if [[ "$mode_line" == "do-not-disturb" ]]; then
      # Notifications are disabled, so we enable them
      makoctl mode -r do-not-disturb
      notify-send 'Notifications Enabled' --expire-time=1500
    else
      # Notifications are enabled, so we disable them
      notify-send 'Notifications Disabled' --expire-time=1500
      sleep 2
      makoctl mode -a do-not-disturb
    fi
  '';

  # Pin a floating window to all workspaces on Sway
  pin-window = ''
    #!/usr/bin/env bash

    # Get the current border style of the focused window
    current_style=$(swaymsg -t get_tree | jq -r '.. | select(.focused?).border')
    
    # Toggle between "normal" (default) and "pixel 3" border styles
    if [ "$current_style" == "none" ]; then
      swaymsg "sticky disable, border pixel 3"
    else
      swaymsg "sticky enable, border none"
    fi
  '';

  # Use grim and slurp to take screenshots in multiple ways
  screenshots = ''
    #!/usr/bin/env bash
    
    # Swappy
    handle_swappy() {
      # Create an imv window to act as a static screen
      grim -t ppm - | imv_config=~/.config/imv/screenshot.ini imv - &
      imv_pid=$!
       
      # Capture the screenshot of the selected area and save to a temporary file
      selected_area=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'\
      | XCURSOR_SIZE=40 slurp -w 3 -c ${primecol} -B 00000066 -b 00000099)
      temp_file=$(mktemp -u).png
      grim -g "$selected_area" "$temp_file"
      
      # Kill the imv window
      kill $imv_pid
      
      # Copy the screenshot to the clipboard
      swappy -f - < "$temp_file"
      
      # Clean up the temporary file
      rm "$temp_file"
    }
    
    # Copy
    handle_copy() {
      # Create an imv window to act as a static screen
      grim -t ppm - | imv_config=~/.config/imv/screenshot.ini imv - &
      imv_pid=$!
       
      # Capture the screenshot of the selected area and save to a temporary file
      selected_area=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'\
      | XCURSOR_SIZE=40 slurp -w 3 -c ${primecol} -B 00000066 -b 00000099)
      temp_file=$(mktemp -u).png
      grim -g "$selected_area" "$temp_file"
      
      # Kill the imv window
      kill $imv_pid
      
      # Copy the screenshot to the clipboard
      wl-copy < "$temp_file" && notify-send -i "$temp_file" "Screenshot copied."
      
      # Clean up the temporary file
      rm "$temp_file"
    }
    
    # Current
    handle_current() {
      # Take a screenshot and save it to the temporary file
      temp_file=$(mktemp -u).png
      grim -o $(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name') "$temp_file"
      
      # Check if the screenshot was successfully taken
      if [ $? -eq 0 ]; then
        # Copy the screenshot to the clipboard
        wl-copy < "$temp_file"
        
        # Show a notification with the screenshot
        notify-send -i "$temp_file" "Current screen copied."
      
        # Remove the temporary file
        rm "$temp_file"
      else
        # If the screenshot capture failed, show an error notification
        notify-send "Error: Unable to capture screenshot."
      fi
    }
    
    # All screens
    handle_all() {
      # Take a screenshot and save it to the temporary file
      temp_file=$(mktemp -u).png
      grim "$temp_file"
      
      # Check if the screenshot was successfully taken
      if [ $? -eq 0 ]; then
        # Copy the screenshot to the clipboard
        wl-copy < "$temp_file"
        
        # Show a notification with the screenshot
        notify-send -i "$temp_file" "All screen copied."
      
        # Remove the temporary file
        rm "$temp_file"
      else
        # If the screenshot capture failed, show an error notification
        notify-send "Error: Unable to capture screenshot."
      fi
    }
    
    # Check for command-line arguments
    if [ "$1" == "--swappy" ]; then
      handle_swappy
    elif [ "$1" == "--copy" ]; then
      handle_copy
    elif [ "$1" == "--current" ]; then
      handle_current
    elif [ "$1" == "--all" ]; then
      handle_all
    else
      echo "Please use a valid argument."
    fi
  '';

  # Kill a window or probe it for info
  wtools = ''
    #!/usr/bin/env bash

    # List the app name and whether or not it uses wayland
    wprop() {
      selected_window=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | slurp -r -c ${primecol} -B 00000066 -b 00000000)
      if [ -n "$selected_window" ]; then
	app_id=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | select("\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" == "'"$selected_window"'") | .app_id')
	system=$(sed 's/xdg_shell/Wayland/g; s/xwayland/Xorg/g' < <(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | select("\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" == "'"$selected_window"'") | .shell'))
	notify-send "$(echo -e "Window's app_id: $app_id\nWindow System: $system")"
      fi
    }
    
    # Kill a selected window
    wkill() {
      selected_window=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | slurp -r -c ${primecol} -B 00000066 -b 00000000)
      if [ -n "$selected_window" ]; then
	pid=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | select("\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" == "'"$selected_window"'") | .pid')
	kill -9 "$pid"
      fi
    }
    
    # Handle which tool we use
    if [ "$1" == "--prop" ]; then
      wprop
    elif [ "$1" == "--kill" ]; then
      wkill
    fi
  '';

  # Fix disks when they are corrupted by my VM setup
  disk-cleanup = ''
    #!/usr/bin/env bash

    # Define mount points and devices
    MOUNT1="/mnt/Linux1"
    MOUNT2="/mnt/Linux2"
    
    # Get device names
    DEVICE_1=$(df -P "$MOUNT1" | awk 'NR==2 {print $1}')
    DEVICE_2=$(df -P "$MOUNT2" | awk 'NR==2 {print $1}')
    
    # Defrag both devices
    sudo e4defrag -c $MOUNT1
    sudo e4defrag -c $MOUNT2
    
    # Unmount both mount points
    sudo umount "$MOUNT1"
    sudo umount "$MOUNT2"
    
    # Run fsck on the devices
    sudo fsck -f "$DEVICE_1"
    sudo e2fsck -f $DEVICE_1
    sudo fsck -f "$DEVICE_2"
    sudo e2fsck -f $DEVICE_2
    
    # Remount the devices
    sudo mount "$MOUNT1"
    sudo mount "$MOUNT2"
    
    echo "Disks cleaned."
  '';

  # Sometimes Wine and Proton hang in the background. This can kill those processes
  kill-proton = ''
    #!/usr/bin/env bash

    # Terminate Wine and Proton processes with ".exe" or "C:\" in command line
    pkill -f '(\.exe|C:\\)' --signal 9
    
    # Terminate all Wine and Proton processes
    pkill -f '.*(\.|/)(wine|proton).*' --signal 9
  '';

  # Download YouTube videos in Opus format (rather than mp3)
  ytopus = ''
    #!/usr/bin/env bash

    # Check if an argument (URL) was provided
    if [ $# -eq 0 ]; then
      echo "No URL provided. Please provide a URL as an argument."
      exit 1
    fi
    
    # Use yt-dlp to download the URL
    yt-dlp "$1"
    
    # Take the downloaded video as a variable
    video=$(ls --color=never *.webm)
    
    # Rewrite the name
    name=$(echo "$video" | awk -F ' \\[.*\\]\\.' '{print $1"."$2}' | sed 's/\.webm$/.opus/')
    
    # Re-encode as opus and make sure it reflects the current date
    ffmpeg -i "$video" -c:a libopus "$name"
    touch "$name"
    
    # Remove the .webm
    rm "$video"
  '';

  # Handle all my alarms
  alarms = ''
    #!/usr/bin/env bash

    # The alarm script itself
    alarm() {
      mpv --volume=90 ${swayscripts}/alarm.mp3 &
      swaynag \
      --message "$name" \
      --button "Stop Alarm" ${swayscripts}/alarmtest.sh \
      --font Ubuntu 12 --background ${darkcol} \
      --border ${primecol} \
      --button-border-size 3 \
      --button-background ${darkcol} \
      --border-bottom ${primecol} \
      --text ${textcolor} \
      --button-text ${textcolor}
    }
    
    # Handle alarm times
    handle_alarms() {

      # Make the script loop when ran by Sway
      while true; do
        # Check the current day and time
        current_day=$(date +"%A")
        current_time=$(date +'%l:%M%p' | sed 's/^ //')
        
        # Monday alarms
        if [ "$current_day" == "Monday" ] && [ "$current_time" == "11:39AM" ]; then
          name="OPS-345 Online"; alarm
        fi
        if [ "$current_day" == "Monday" ] && [ "$current_time" == "1:25PM" ]; then
          name="MST-200 Online"; alarm
        fi
        if [ "$current_day" == "Monday" ] && [ "$current_time" == "3:15PM" ]; then
          name="DAT-330_Online"; alarm
        fi
        
        # Tuesday alarms
        if [ "$current_day" == "Tuesday" ] && [ "$current_time" == "10:40AM" ]; then
          name="CUL-200 Check for In Person"; alarm
        fi
    
        # Wednesday alarms
        
        # Thursday alarms
        if [ "$current_day" == "Thursday" ] && [ "$current_time" == "11:20AM" ]; then
          name="MST-200 In Person"; alarm
        fi
        
        # Friday alarms
        if [ "$current_day" == "Friday" ] && [ "$current_time" == "08:00AM" ]; then
          name="OPS-345 In Person"; alarm
        fi
        
        # Wait a minute between checks
        sleep 60
      done
    }
    
    # Handle the killing of the alarm
    kill_alarm() {
      pkill -f 'mpv.*alarm'
      pkill swaynag
    }
    
    # Check which mode the script is ran in
    if [ "$1" == "--alarms" ]; then
      handle_alarms
    else
      kill_alarm
    fi
  '';

  # Define Waybar config
  waybarconfig = ''
    [{
      // Bar 1
      "name": "bar1",
      "position": "top",
      "layer": "bottom",
      "output": "${monitor1}",
      "modules-left": ["sway/workspaces", "sway/window"],
      "modules-right": ["pulseaudio", "cpu", "memory", "custom/vram", "custom/clock-long", "gamemode", "sway/scratchpad", "tray", "network"],
    
      "sway/workspaces": {
        "format": "{name}",
        "enable-bar-scroll": true,
        "warp-on-scroll": false,
        "disable-scroll-wraparound": true
      },
    
      "sway/window": {
        "icon": true,
        "icon-size": 15,
        "all-outputs": true,
        "tooltip": false,
        "rewrite": {
          "(.*) — LibreWolf": "   $1",
          "LibreWolf": "   LibreWolf",
          "(.*) - YouTube — LibreWolf": "󰗃   $1"
        }
      },
    
      "pulseaudio": {
        "format": "{icon}   {volume}%",
        "format-bluetooth": "{icon}  {volume}%",
        "format-muted": " muted",
        "format-icons": {
          "headphone": "",
          "default": ["", ""]
        },
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-click-middle": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%",
        "on-click-right": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 60%",
        "ignored-sinks": ["Easy Effects Sink","USB FS AUDIO Analog Stereo"]
      },
    
      "cpu": {
        "format": "  {usage}%",
        "interval": 3
      },
    
      "memory": {
        "format": "  {used}G",
        "tooltip": false
      },
    
      "custom/vram": {
        "exec": "${swaycfg}/waybar/scripts/vram.sh",
        "format": "{}",
        "return-type": "json",
        "interval": 3
      },
    
      "custom/clock-long": {
        "exec": "${swaycfg}/waybar/scripts/clock-long.sh",
        "on-click": "wl-copy $(date \"+%Y-%m-%d-%H%M%S\"); notify-send \"Date copied.\"",
        "format": "{}",
        "return-type": "json",
        "interval": 1,
        "tooltip": true
      },
    
      "gamemode": {
        "format": "{glyph}",
        "glyph": "󰖺",
        "hide-not-running": true,
        "use-icon": true,
        "icon-spacing": 3,
        "icon-size": 19,
        "tooltip": true,
        "tooltip-format": "Gamemode: On"
      },
    
      "sway/scratchpad": {
        "format": "   {count}",
        "show-empty": false,
        "tooltip": true,
        "tooltip-format": "{title}"
      },
    
      "tray": {
        "spacing": 5
      },
    
      "network": {
        "interface": "enp42s0",
        //"interface": "enp15s0",
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "󰈀",
        "format-disconnected": "󰖪",
        "format-linked": "",
        "tooltip-format-wifi": "{essid} ({signalStrength}%) \n{ifname}",
        "tooltip-format-ethernet": "{ipaddr}\n{ifname} ",
        "tooltip-format-disconnected": "Disconnected"
      }
    },{
      // Bar 2
      "name": "bar2",
      "position": "top",
      "layer": "bottom",
      "output": "DP-1",
      "modules-left": ["sway/workspaces", "sway/window"],
      "modules-right": ["pulseaudio", "custom/media", "custom/notifs", "cpu", "memory", "custom/vram", "custom/clock-long"],
    
      "sway/workspaces": {
        "format": "{name}",
        "enable-bar-scroll": true,
        "warp-on-scroll": false,
        "disable-scroll-wraparound": true
      },
    
      "sway/window": {
        "icon": true,
        "icon-size": 15,
        "all-outputs": true,
        "tooltip": false,
        "rewrite": {
          "(.*) — LibreWolf": "   $1",
          "LibreWolf": "   LibreWolf",
          "(.*) - YouTube — LibreWolf": "󰗃   $1"
        }
      },
    
      "pulseaudio": {
        "format": "{icon}   {volume}%",
        "format-bluetooth": "{icon}  {volume}%",
        "format-muted": " muted",
        "format-icons": {
          "headphone": "",
          "default": ["", ""]
        },
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-click-middle": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%",
        "on-click-right": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 60%",
        "ignored-sinks": ["Easy Effects Sink","USB FS AUDIO Analog Stereo"]
      },
    
      "custom/media": {
        "exec-if": "playerctl --player=mpv status",
        "exec": "${swaycfg}/waybar/scripts/mpv-metadata.sh",
        "format": "{}",
        "return-type": "json",
        "interval": 2,
        "max-length": 30,
        "on-click": "playerctl --player=mpv play-pause",
        "on-click-middle": "pkill -9 mpv"
      },
    
      "custom/notifs": {
        "exec": "${swaycfg}/waybar/scripts/notif-status.sh",
        "format": "{}",
        "return-type": "json",
        "interval": 2,
        "on-click": "${swayscripts}/desktop/notif-toggle.sh"
      },
    
      "cpu": {
        "format": "  {usage}%",
        "interval": 3
      },
    
      "memory": {
        "format": "  {used}G",
        "tooltip": false
      },
    
      "custom/vram": {
        "exec": "${swaycfg}/waybar/scripts/vram.sh",
        "format": "{}",
        "return-type": "json",
        "interval": 3
      },
    
      "custom/clock-long": {
        "exec": "${swaycfg}/waybar/scripts/clock-long.sh",
        "on-click": "wl-copy $(date \"+%Y-%m-%d-%H%M%S\"); notify-send \"Date copied.\"",
        "format": "{}",
        "return-type": "json",
        "interval": 1,
        "tooltip": true
      }
    },{
      // Bar 3
      "name": "bar3",
      "position": "top",
      "layer": "bottom",
      "output": "DP-2",
      "modules-left": ["sway/workspaces", "sway/window"],
      "modules-right": [ "pulseaudio", "custom/weather", "cpu", "memory", "custom/vram", "custom/clock-short"],
    
      "sway/workspaces": {
        "format": "{name}",
        "enable-bar-scroll": true,
        "warp-on-scroll": false,
        "disable-scroll-wraparound": true
      },
    
      "sway/window": {
        "icon": true,
        "icon-size": 15,
        "all-outputs": true,
        "tooltip": false,
        "rewrite": {
          "(.*) — LibreWolf": "   $1",
          "LibreWolf": "   LibreWolf",
          "(.*) - YouTube — LibreWolf": "󰗃   $1"
        }
      },
    
      "pulseaudio": {
        "format": "{icon}   {volume}%",
        "format-bluetooth": "{icon}  {volume}%",
        "format-muted": " muted",
        "format-icons": {
          "headphone": "",
          "default": ["", ""]
        },
        "on-click": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
        "on-click-middle": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%",
        "on-click-right": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 60%",
        "ignored-sinks": ["Easy Effects Sink","USB FS AUDIO Analog Stereo"]
      },
    
      "custom/weather": {
        "exec": "${swaycfg}/waybar/scripts/weather.sh",
        "format": "<span font_size='11pt'>{}</span>",
        "return-type": "json",
        "on-click": "librewolf https://openweathermap.org/city/6173577",
        "interval": 150
      },
    
      "cpu": {
        "format": "  {usage}%",
        "interval": 3
      },
    
      "memory": {
        "format": "  {used}G",
        "tooltip": false
      },
    
      "custom/vram": {
        "exec": "${swaycfg}/waybar/scripts/vram.sh",
        "format": "{}",
        "return-type": "json",
        "interval": 5
      },
    
      "custom/clock-short": {
        "exec": "echo '  '$(date +'%l:%M%p' | sed 's/^ //')",
        "on-click": "wl-copy $(date \"+%Y-%m-%d-%H%M%S\"); notify-send \"Date copied.\"",
        "interval": 60,
        "tooltip": false
      }
    }]
    // vi:syntax=json:
  '';

  # The theming of my waybar
  waybarstyle = ''
    * {
      border: 0;
      border-radius: 0;
      min-height: 0;
      font-family: Ubuntu, UbuntuMono Nerd Font;
      color: #${textcolor};
    }
    .bar1,.bar2,.bar3 {
      font-size: 15.5px;
    }
    #waybar {
      background: #${darkcol};
    }
    #workspaces {
      padding: 0 6px 0 0;
    }
    #tray {
      padding: 0 4px 0 5px;
    }
    #network {
      padding: 0 10px 0 2.1px;
    }
    #network.disconnected {
      color: #424242;
    }
    #workspaces button {
      padding: 0 3px;
      color: white;
      border-bottom: 3px solid transparent;
      min-width: 20px;
    }
    #workspaces button.visible {
      border-bottom: 3px solid #${primecol};
      background: #${midcol};
    }
    #workspaces button.urgent {
      border-bottom: 3px solid #900000;
    }
    #workspaces button:hover {
      box-shadow: none;
      background: #${splitcol};
    }
    #custom-clock-long {
      border-bottom: 3px solid #0a6cf5;
      margin-left: 2px;
      margin-right: 5px;
    }
    #scratchpad {
      margin-left: 2px;
    }
    #custom-clock-short {
      border-bottom: 3px solid #0a6cf5;
      margin-left: 2px;
      margin-right: 3px;
    }
    #memory {
      border-bottom: 3px solid #4bffdc;
      margin-left: 2px;
      margin-right: 5px;
    }
    #custom-vram {
      border-bottom: 3px solid #33FF00;
      margin-left: 2px;
      margin-right: 5px;
    }
    #cpu {
      border-bottom: 3px solid #f90000;
      margin-left: 2px;
      margin-right: 5px;
    }
    #custom-media {
      border-bottom: 3px solid #ffb066;
      margin-left: 2px;
      margin-right: 5px;
    }
    #custom-media.paused {
      color: #888;
    }
    #custom-weather {
      border-bottom: 3px solid #${primecol};
      margin-left: 2px;
      margin-right: 5px;
    }
    #custom-notifs {
      border-bottom: 3px solid #${primecol};
      margin-left: 2px;
      margin-right: 5px;
    }
    #custom-notifs.disabled {
      color: #888;
    }
    #pulseaudio {
      margin-right: 5px;
    }
    #pulseaudio.muted {
      color: #424242;
    }
  '';

  # Waybar's start script (used for hotkeys)
  waybarstart = ''
    #!/usr/bin/env bash
    pkill waybar; waybar -c ${waybarcfg}/config -s ${waybarcfg}/style.css
  '';

  # Waybar's clock-long script
  clocklong = ''
    #!/usr/bin/env bash

    # Long clock format, with a numeric date and military time tooltip
    time=$(date +'%a %b %d %l:%M:%S%p' | tr -s ' ')
    date=$(date "+%Y-%m-%d")
    echo "{\"text\":\"  $time\",\"tooltip\":\"$date\"}"
  '';

  # Waybar's MPV Playerctl Module
  mpvmeta = ''
    #!/usr/bin/env bash
    
    get_metadata() {
      playerctl --player=mpv metadata 2>/dev/null |
        awk '/title/{gsub(/\.(mp3|mp4|m4a|mov|flac|opus|oga)$/,""); for (i=3; i<NF; i++) printf $i " "; printf $NF "\n"}'
    }
    
    truncate_string() {
      local str="$1"
      local max_length=30
      if [ $(expr length "$str") -gt $max_length ]; then
	str=$(expr substr "$str" 1 $max_length)...
      fi
      echo "$str"
    }
    
    if playerctl --player=mpv status 2>/dev/null | grep -q Playing; then
      song_name=$(get_metadata | awk -F ' - ' '{print $2}')
      if [ -z "$song_name" ]; then
        song_name=$(get_metadata)
      fi
      echo "{\"text\":\"$(truncate_string "  $song_name")\",\"tooltip\":\"$(get_metadata)\"}"
    elif playerctl --player=mpv status 2>/dev/null | grep -q Paused; then
      artist_name=$(get_metadata | awk -F ' - ' '{print $1}')
      if [ -z "$artist_name" ]; then
        artist_name=$(get_metadata)
      fi
      echo "{\"text\":\"$(truncate_string "  $artist_name")\",\"tooltip\":\"$(get_metadata)\",\"class\":\"paused\"}"
    fi
  '';

  # Notification status for Waybar
  notifstatus = ''
    #!/usr/bin/env bash
    
    # Run makoctl mode and store the output in a variable
    mode_output=$(makoctl mode)
    
    # Extract the second line after "default"
    mode_line=$(echo "$mode_output" | sed -n '/default/{n;p}')
    
    # Print the notification status with the tooltip
    if [[ "$mode_line" == "do-not-disturb" ]]; then
      printf '{"text":"󱆥  Off","class":"disabled","tooltip":"Notifications Disabled."}'
    else
      printf '{"text":"  On","tooltip":"Notifications Enabled."}';
    fi
  '';

  # Waybar vram monitor
  vram = ''
    #!/usr/bin/env bash

    # Run the nvidia-smi command and capture the VRAM usage and GPU utilization output
    if lspci -k | grep "Kernel driver in use: nvidia" &> /dev/null; then
      vram_usage_mb=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
      temperature=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    elif lspci -k | grep "Kernel driver in use: amdgpu" &> /dev/null; then
      vram_usage_mb=$(echo "$(cat /sys/class/drm/card0/device/mem_info_vram_used || cat /sys/class/drm/card1/device/mem_info_vram_used) / 1024 / 1024" | bc)
      temperature=$(sensors | grep 'edge' | awk '{print $2}' | sed 's/[^0-9.-]//g')
    fi
    
    # Check if VRAM usage is under 1GB
    if [ $vram_usage_mb -lt 1024 ]; then
      vram_usage_display="$(echo $vram_usage_mb)M"
    else
      # Convert MB to GiB
      vram_usage_gib=$(bc <<< "scale=2; $vram_usage_mb / 1024")
      vram_usage_display="$(echo $vram_usage_gib)G"
    fi
    
    # Print the VRAM usage in MB or GiB, and include GPU utilization and temperature
    echo "{\"text\":\"󰢮  $(echo $vram_usage_display)\",\"tooltip\":\"$(echo $temperature)°C\"}"
  '';

  # Weather script for Waybar
  weather = ''
    #!/usr/bin/env bash

    # Define variables
    CITY="Maple"
    API_KEY="18be8db3528f08c33ed9f95698335ea7"
    
    # Fetch weather data
    weather_data=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=$CITY&appid=$API_KEY")
    weather_condition=$(echo $weather_data | jq -r '.weather[0].main')
    
    # Map weather conditions to emojis
    case "$weather_condition" in
      "Clear") emoji="☀️";;
      "Clouds") emoji="☁️";;
      "Rain") emoji="🌧️";;
      "Drizzle") emoji="🌦️";;
      "Thunderstorm") emoji="⛈️";;
      "Snow") emoji="❄️";;
      "Mist"|"Fog"|"Haze") emoji="🌫️";;
      *) emoji="🌍";; # Default emoji for unknown conditions
    esac
    
    # Extract and format temperature in Celsius
    temperature_kelvin=$(echo $weather_data | jq -r '.main.temp')
    temperature_celsius=$(echo "$temperature_kelvin - 273.15" | bc)
    formatted_temperature=$(printf "%.0f" $temperature_celsius)
    
    # Display weather emoji and temperature
    echo {\"text\":\"$emoji $formatted_temperature°C\",\"tooltip\":\"Weather in Maple: $weather_condition\"}
  '';

  # File manager config
  pcmanconf = ''
    [Behavior]
    BookmarkOpenMethod=current_tab
    ConfirmDelete=true
    RecentFilesNumber=0
    
    [Desktop]
    HideItems=false
    SortColumn=name
    SortFolderFirst=true
    SortHiddenLast=false
    SortOrder=ascending
    
    [FolderView]
    BigIconSize=48
    CustomColumnWidths=@Invalid()
    FolderViewCellMargins=@Size(3 3)
    HiddenColumns=@Invalid()
    Mode=icon
    ScrollPerPixel=true
    ShadowHidden=true
    ShowFilter=false
    ShowFullNames=true
    ShowHidden=true
    SidePaneIconSize=24
    SmallIconSize=24
    SortCaseSensitive=false
    SortColumn=mtime
    SortFolderFirst=true
    SortHiddenLast=false
    SortOrder=descending
    ThumbnailIconSize=128
    
    [Places]
    HiddenPlaces=menu://applications/
    
    [System]
    Archiver=file-roller
    Terminal=kitty
    
    [Thumbnail]
    MaxExternalThumbnailFileSize=-1
    MaxThumbnailFileSize=4096
    ShowThumbnails=true
    ThumbnailLocalFilesOnly=true
    
    [Volume]
    AutoRun=true
    CloseOnUnmount=true
    MountOnStartup=true
    MountRemovable=true
    
    [Window]
    AlwaysShowTabs=false
    PathBarButtons=true
    ShowMenuBar=true
    ShowTabClose=true
    SwitchToNewTab=true
    TabPaths=@Invalid()
  '';

  # Kitty config
  kittyconfig = ''
    # kitty.conf

    # Scrolling
    scrollback_lines 50000
    
    # Font
    font_family UbuntuMono Nerd Font
    bold_font UbuntuMono Nerd Font
    italic_font UbuntuMono Nerd Font
    bold_italic_font UbuntuMono Nerd Font
    font_size 15
    
    # Colors
    background #${darkcol}
    foreground #F9F9F9
    
    color0   #3f3f3f
    color1   #cc0000
    color2   #4e9a06
    color3   #c4a000
    color4   #94bff3
    color5   #85678f
    color6   #06989a
    color7   #dcdccc
    
    color8   #545454
    color9   #fc5454
    color10  #8ae234
    color11  #fce94f
    color12  #94bff3
    color13  #b294bb
    color14  #93e0e3
    color15  #ffffff
    
    # Window opacity
    background_opacity 0.71
    
    # Cursor
    cursor_shape beam
    
    # No confirm close
    confirm_os_window_close 0
    
    # Clear all default shortcuts
    clear_all_shortcuts yes
    clear_all_mouse_actions yes
    
    # Rebind copy-paste, text selection
    map ctrl+shift+c copy_to_clipboard
    map ctrl+shift+v paste_from_clipboard
    
    # Scroll up and down
    map ctrl+page_up scroll_page_up
    map ctrl+page_down scroll_page_down
    
    # Change font size
    map ctrl+shift+equal change_font_size all +2.0
    map ctrl+shift+minus change_font_size all -2.0
    
    # Manage tui app clicking
    mouse_map left press ungrabbed mouse_selection normal
    mouse_map shift+left press ungrabbed,grabbed mouse_selection normal
    mouse_map shift+left click grabbed,ungrabbed mouse_handle_click selection link prompt
    
    # Select words and lines with the mouse
    mouse_map left doublepress ungrabbed mouse_selection word
    mouse_map shift+left doublepress ungrabbed,grabbed mouse_selection word
    mouse_map left triplepress ungrabbed mouse_selection line
    mouse_map shift+left triplepress ungrabbed,grabbed mouse_selection line
    
    # Search function
    map ctrl+f launch --location=hsplit --allow-remote-control kitty +kitten search.py @active-kitty-window-id
  '';

  # Kitty scrollback search script written in python
  kittysearch = ''
    import json
    import re
    import subprocess
    from gettext import gettext as _
    from pathlib import Path
    from subprocess import PIPE, run
    
    from kittens.tui.handler import Handler
    from kittens.tui.line_edit import LineEdit
    from kittens.tui.loop import Loop
    from kittens.tui.operations import (
      clear_screen,
      cursor,
      set_line_wrapping,
      set_window_title,
      styled,
    )
    from kitty.config import cached_values_for
    from kitty.key_encoding import EventType
    from kitty.typing import KeyEventType, ScreenSize
    
    NON_SPACE_PATTERN = re.compile(r"\S+")
    SPACE_PATTERN = re.compile(r"\s+")
    SPACE_PATTERN_END = re.compile(r"\s+$")
    SPACE_PATTERN_START = re.compile(r"^\s+")
    
    NON_ALPHANUM_PATTERN = re.compile(r"[^\w\d]+")
    NON_ALPHANUM_PATTERN_END = re.compile(r"[^\w\d]+$")
    NON_ALPHANUM_PATTERN_START = re.compile(r"^[^\w\d]+")
    ALPHANUM_PATTERN = re.compile(r"[\w\d]+")
    
    def call_remote_control(args: list[str]) -> None:
        subprocess.run(["kitty", "@", *args], capture_output=True)
    
    def reindex(
      text: str, pattern: re.Pattern[str], right: bool = False
    ) -> tuple[int, int]:
      if not right:
        m = pattern.search(text)
      else:
        matches = [x for x in pattern.finditer(text) if x]
        if not matches:
          raise ValueError
          m = matches[-1]
    
        if not m:
          raise ValueError
        return m.span()
    
    SCROLLMARK_FILE = Path(__file__).parent.absolute() / "scroll_mark.py"
    
    class Search(Handler):
      def __init__(
        self, cached_values: dict[str, str], window_ids: list[int], error: str = ""
      ) -> None:
        self.cached_values = cached_values
        self.window_ids = window_ids
        self.error = error
        self.line_edit = LineEdit()
        last_search = cached_values.get("last_search", "")
        self.line_edit.add_text(last_search)
        self.text_marked = bool(last_search)
        self.mode = cached_values.get("mode", "text")
        self.update_prompt()
        self.mark()
    
      def update_prompt(self) -> None:
        self.prompt = "~> " if self.mode == "regex" else "=> "
    
      def init_terminal_state(self) -> None:
        self.write(set_line_wrapping(False))
        self.write(set_window_title(_("Search")))
    
      def initialize(self) -> None:
        self.init_terminal_state()
        self.draw_screen()
    
      def draw_screen(self) -> None:
        self.write(clear_screen())
        if self.window_ids:
          input_text = self.line_edit.current_input
          if self.text_marked:
            self.line_edit.current_input = styled(input_text, reverse=True)
          self.line_edit.write(self.write, self.prompt)
          self.line_edit.current_input = input_text
        if self.error:
          with cursor(self.write):
            self.print("")
            for l in self.error.split("\n"):
              self.print(l)
    
      def refresh(self) -> None:
        self.draw_screen()
        self.mark()
    
      def switch_mode(self) -> None:
        if self.mode == "regex":
          self.mode = "text"
        else:
          self.mode = "regex"
        self.cached_values["mode"] = self.mode
        self.update_prompt()
    
      def on_text(self, text: str, in_bracketed_paste: bool = False) -> None:
        if self.text_marked:
          self.text_marked = False
          self.line_edit.clear()
        self.line_edit.on_text(text, in_bracketed_paste)
        self.refresh()
    
      def on_key(self, key_event: KeyEventType) -> None:
        if (
          self.text_marked
          and key_event.type == EventType.PRESS
          and key_event.key
          not in [
            "TAB",
            "LEFT_CONTROL",
            "RIGHT_CONTROL",
            "LEFT_ALT",
            "RIGHT_ALT",
            "LEFT_SHIFT",
            "RIGHT_SHIFT",
            "LEFT_SUPER",
            "RIGHT_SUPER",
          ]
        ):
            self.text_marked = False
            self.refresh()
    
        if self.line_edit.on_key(key_event):
          self.refresh()
          return
    
        if key_event.matches("ctrl+u"):
          self.line_edit.clear()
          self.refresh()
        elif key_event.matches("ctrl+a"):
          self.line_edit.home()
          self.refresh()
        elif key_event.matches("ctrl+e"):
          self.line_edit.end()
          self.refresh()
        elif key_event.matches("ctrl+backspace") or key_event.matches("ctrl+w"):
          before, _ = self.line_edit.split_at_cursor()
    
          try:
            start, _ = reindex(before, SPACE_PATTERN_END, right=True)
          except ValueError:
            start = -1
    
          try:
            space = before[:start].rindex(" ")
          except ValueError:
            space = 0
          self.line_edit.backspace(len(before) - space)
          self.refresh()
        elif key_event.matches("ctrl+left") or key_event.matches("ctrl+b"):
          before, _ = self.line_edit.split_at_cursor()
          try:
            start, _ = reindex(before, SPACE_PATTERN_END, right=True)
          except ValueError:
            start = -1
    
          try:
            space = before[:start].rindex(" ")
          except ValueError:
            space = 0
          self.line_edit.left(len(before) - space)
          self.refresh()
        elif key_event.matches("ctrl+right") or key_event.matches("ctrl+f"):
          _, after = self.line_edit.split_at_cursor()
          try:
            _, end = reindex(after, SPACE_PATTERN_START)
          except ValueError:
            end = 0
    
          try:
            space = after[end:].index(" ") + 1
          except ValueError:
            space = len(after)
          self.line_edit.right(space)
          self.refresh()
        elif key_event.matches("alt+backspace") or key_event.matches("alt+w"):
          before, _ = self.line_edit.split_at_cursor()
    
          try:
            start, _ = reindex(before, NON_ALPHANUM_PATTERN_END, right=True)
          except ValueError:
            start = -1
          else:
            self.line_edit.backspace(len(before) - start)
            self.refresh()
            return
    
          try:
            start, _ = reindex(before, NON_ALPHANUM_PATTERN, right=True)
          except ValueError:
            self.line_edit.backspace(len(before))
            self.refresh()
            return
    
          self.line_edit.backspace(len(before) - (start + 1))
          self.refresh()
        elif key_event.matches("alt+left") or key_event.matches("alt+b"):
          before, _ = self.line_edit.split_at_cursor()
    
          try:
            start, _ = reindex(before, NON_ALPHANUM_PATTERN_END, right=True)
          except ValueError:
            start = -1
          else:
            self.line_edit.left(len(before) - start)
            self.refresh()
            return
    
          try:
            start, _ = reindex(before, NON_ALPHANUM_PATTERN, right=True)
          except ValueError:
            self.line_edit.left(len(before))
            self.refresh()
            return
    
          self.line_edit.left(len(before) - (start + 1))
          self.refresh()
        elif key_event.matches("alt+right") or key_event.matches("alt+f"):
          _, after = self.line_edit.split_at_cursor()
    
          try:
            _, end = reindex(after, NON_ALPHANUM_PATTERN_START)
          except ValueError:
            end = 0
          else:
            self.line_edit.right(end)
            self.refresh()
            return
    
          try:
            _, end = reindex(after, NON_ALPHANUM_PATTERN)
          except ValueError:
            self.line_edit.right(len(after))
            self.refresh()
            return
    
          self.line_edit.right(end - 1)
          self.refresh()
        elif key_event.matches("tab"):
          self.switch_mode()
          self.refresh()
        elif key_event.matches("up"):
          for match_arg in self.match_args():
            call_remote_control(["kitten", match_arg, str(SCROLLMARK_FILE)])
        elif key_event.matches("down"):
          for match_arg in self.match_args():
            call_remote_control(["kitten", match_arg, str(SCROLLMARK_FILE), "next"])
        elif key_event.matches("enter"):
          self.quit(0)
        elif key_event.matches("esc"):
          self.quit(1)
    
      def on_interrupt(self) -> None:
        self.quit(1)
    
      def on_eot(self) -> None:
        self.quit(1)
    
      def on_resize(self, screen_size: ScreenSize) -> None:
        self.refresh()
    
      def match_args(self) -> list[str]:
        return [f"--match=id:{window_id}" for window_id in self.window_ids]
    
      def mark(self) -> None:
        if not self.window_ids:
          return
        text = self.line_edit.current_input
        if text:
          match_case = "i" if text.islower() else ""
          match_type = match_case + self.mode
          for match_arg in self.match_args():
            try:
              call_remote_control(
                ["create-marker", match_arg, match_type, "1", text]
              )
            except SystemExit:
              self.remove_mark()
        else:
          self.remove_mark()
    
      def remove_mark(self) -> None:
        for match_arg in self.match_args():
          call_remote_control(["remove-marker", match_arg])
    
      def quit(self, return_code: int) -> None:
        self.cached_values["last_search"] = self.line_edit.current_input
        self.remove_mark()
        if return_code:
          for match_arg in self.match_args():
            call_remote_control(["scroll-window", match_arg, "end"])
        self.quit_loop(return_code)
    
    
    def main(args: list[str]) -> None:
      call_remote_control(
        ["resize-window", "--self", "--axis=vertical", "--increment", "-100"]
      )
    
      error = ""
      if len(args) < 2 or not args[1].isdigit():
        error = "Error: Window id must be provided as the first argument."
    
      window_id = int(args[1])
      window_ids = [window_id]
      if len(args) > 2 and args[2] == "--all-windows":
        ls_output = run(["kitty", "@", "ls"], stdout=PIPE)
        ls_json = json.loads(ls_output.stdout.decode())
        current_tab = None
        for os_window in ls_json:
          for tab in os_window["tabs"]:
            for kitty_window in tab["windows"]:
              if kitty_window["id"] == window_id:
                current_tab = tab
        if current_tab:
          window_ids = [
            w["id"] for w in current_tab["windows"] if not w["is_focused"]
          ]
        else:
          error = "Error: Could not find the window id provided."
    
      loop = Loop()
      with cached_values_for("search") as cached_values:
        handler = Search(cached_values, window_ids, error)
        loop.loop(handler)
  '';

  # The search keys don't work without this additional script
  kittysearchkeys = ''
    from kittens.tui.handler import result_handler
    from kitty.boss import Boss
    
    def main(args: list[str]) -> None:
      pass
    
    @result_handler(no_ui=True)
    def handle_result(
      args: list[str], answer: str, target_window_id: int, boss: Boss
    ) -> None:
      w = boss.window_id_map.get(target_window_id)
      if w is not None:
        if len(args) > 1 and args[1] != "prev":
          w.scroll_to_mark(prev=False)
        else:
          w.scroll_to_mark()
  '';

  # Dashboard for my Debian server
  kittydash = pkgs.writeTextFile {
    name = "kittydash";
    destination = "/bin/kittydash";
    executable = true;
    text = ''
      kitty --class=serverdash kitten ssh 192.168.1.17 -t "tmux attach -t control"
    '';
  };

  # Additional IMV mode
  imvshot = ''
    [options]
    title_text = GlobalShot
  '';

  # An Easyeffects equalizer profile that sounds good to me
  easyprofile = ''
    {
      "output": {
        "blocklist": [],
        "crystalizer#0": {
          "band0": {
            "bypass": false,
            "intensity": 0.0,
            "mute": false
          },
          "band1": {
            "bypass": false,
            "intensity": -1.0,
            "mute": false
          },
          "band10": {
            "bypass": false,
            "intensity": -10.0,
            "mute": false
          },
          "band11": {
            "bypass": false,
            "intensity": -11.0,
            "mute": false
          },
          "band12": {
            "bypass": false,
            "intensity": -12.0,
            "mute": false
          },
          "band2": {
            "bypass": false,
            "intensity": -2.0,
            "mute": false
          },
          "band3": {
            "bypass": false,
            "intensity": -3.0,
            "mute": false
          },
          "band4": {
            "bypass": false,
            "intensity": -4.0,
            "mute": false
          },
          "band5": {
            "bypass": false,
            "intensity": -5.0,
            "mute": false
          },
          "band6": {
            "bypass": false,
            "intensity": -6.0,
            "mute": false
          },
          "band7": {
            "bypass": false,
            "intensity": -7.0,
            "mute": false
          },
          "band8": {
            "bypass": false,
            "intensity": -8.0,
            "mute": false
          },
          "band9": {
            "bypass": false,
            "intensity": -9.0,
            "mute": false
          },
          "bypass": false,
          "input-gain": 0.0,
          "output-gain": 0.0
        },
        "equalizer#0": {
          "balance": 0.0,
          "bypass": false,
          "input-gain": 0.0,
          "left": {
            "band0": {
              "frequency": 32.0,
              "gain": 1.1,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band1": {
              "frequency": 64.0,
              "gain": 1.16,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band2": {
              "frequency": 125.0,
              "gain": 3.33,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band3": {
              "frequency": 250.0,
              "gain": 1.53,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band4": {
              "frequency": 500.0,
              "gain": -1.83,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band5": {
              "frequency": 1000.0,
              "gain": -0.58,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band6": {
              "frequency": 2000.0,
              "gain": 1.42,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band7": {
              "frequency": 4000.0,
              "gain": 4.73,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band8": {
              "frequency": 16000.0,
              "gain": 7.62,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band9": {
              "frequency": 156.38,
              "gain": 2.84,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            }
          },
          "mode": "IIR",
          "num-bands": 10,
          "output-gain": 0.0,
          "pitch-left": 0.0,
          "pitch-right": 0.0,
          "right": {
            "band0": {
              "frequency": 32.0,
              "gain": 1.1,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band1": {
              "frequency": 64.0,
              "gain": 1.16,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band2": {
              "frequency": 125.0,
              "gain": 3.33,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band3": {
              "frequency": 250.0,
              "gain": 1.53,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band4": {
              "frequency": 500.0,
              "gain": -1.83,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band5": {
              "frequency": 1000.0,
              "gain": -0.58,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band6": {
              "frequency": 2000.0,
              "gain": 1.42,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band7": {
              "frequency": 4000.0,
              "gain": 4.73,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band8": {
              "frequency": 16000.0,
              "gain": 7.62,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            },
            "band9": {
              "frequency": 156.38,
              "gain": 2.84,
              "mode": "RLC (BT)",
              "mute": false,
              "q": 4.36,
              "slope": "x1",
              "solo": false,
              "type": "Bell"
            }
          },
          "split-channels": false
        },
        "plugins_order": [
          "equalizer#0",
          "crystalizer#0"
        ]
      }
    }
  '';

  # Mangohud acts like rivatuner on Windows, config file
  mangoconfig = ''
    #!/usr/bin/env bash
    table_columns=2
    frametime=0
    legacy_layout=0
    font_scale=0.80
    background_alpha=0.25
    #frame_timing=0
    #position=top-right
    
    # Set the loads and such
    exec=echo "$(echo $XDG_CURRENT_DESKTOP | sed 's/./\U&/')" on $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2)
    fps
    fps_color_change
    ram
    vram
    cpu_stats
    cpu_load_change
    gpu_stats
    gpu_load_change
    frame_timing
  '';

  # Neofetch main config
  neoconfig = ''
    # Show different info types
    print_info() {
      prin ""
      info "󰌢 " model
      info "󰍛 " cpu
      info "󰘚 " gpu
      info " " disk
      info "󰟖 " memory
      info "󰍹 " resolution
      #info "󱈑 " battery 
      prin ""
      info " " distro
      info " " kernel
      #info " " de
      info " " wm
      info " " shell
      info " " term
      info "󰊠 " packages
      info "󰅐 " uptime
      prin ""
    prin "$white󰮯 \n \n $red󰊠 \n \n $green󰊠  \n \n $yellow󰊠  \n \n $blue󰊠  \n \n $magenta󰊠  \n \n $cyan󰊠  \n \n $reset󰊠"
    }
    
    # Kernel
    kernel_shorthand="off"
    
    # Distro
    distro_shorthand="on"
    os_arch="on"
    
    # Uptime
    uptime_shorthand="off"
    
    # Memory
    memory_percent="off"
    
    # Packages
    package_managers="on"
    shell_path="off"
    shell_version="on"
    
    # CPU
    speed_type="scaling_cur_freq"
    speed_shorthad="on"
    cpu_brand="off"
    cpu_speed="on"
    cpu_cores="logical"
    cpu_temp="C"
    
    # GPU
    gpu_brand="off"
    gpu_type="all"
    
    # Disk
    disk_show=('/')
    
    # Text Options
    separator="  "
    
    # Color Blocks
    white="\033[1;37m"
    red="\033[1;31m"
    green="\033[1;32m"
    yellow="\033[1;33m"
    blue="\033[1;34m"
    magenta="\033[1;35m"
    cyan="\033[1;36m"
    reset="\033[0m"
  '';
  smallconfig = ''
    # Show different info types
    print_info() {
      info title
      info "OS" distro
      info "Host" model
      info "Kernel" kernel
      info "Uptime" uptime
      info "Packages" packages
      info "Memory" memory
    }
    
    # Shorthand info
    kernel_shorthand="on"
    distro_shorthand="on"
    uptime_shorthand="tiny"
    package_managers="off"
    memory_percent="off"
    separator=":"
    
    # Values:  'kib', 'mib', 'gib'
    memory_unit="gib"
  '';

  # Rofi (terminal file browser) config
  rangerconf = ''
    # Ranger settings
    set colorscheme default
    set preview_script ~/.config/ranger/scope.sh
    set preview_images true
    set preview_images_method kitty
    set unicode_ellipsis true
    set dirname_in_tabs true 
    set cd_tab_fuzzy true
    set show_hidden true
    set wrap_scroll true
    set column_ratios 2,2,4
    set hidden_filter ^\.|\.(?:pyc|pyo|bak|swp)$|^lost\+found$|^__(py)?cache__$
  '';

  # Choose how rofi opens stuff
  rifleconf = ''
    # vim: ft=cfg

    # Define the "editor" for text files as first action
    mime ^text,  label editor = nvim -- "$@"
    mime ^text,  label pager  = "$PAGER" -- "$@"
    !mime ^text, label editor, ext xml|json|csv|tex|py|pl|rb|js|sh|php = nvim -- "$@"
    !mime ^text, label pager,  ext xml|json|csv|tex|py|pl|rb|js|sh|php = "$PAGER" -- "$@"
    
    # Websites
    ext x?html?, has librewolf,          X, flag f = librewolf -- "$@"
    
    # Define the "editor" for text files as first action
    mime ^text, label editor = "$EDITOR" -- "$@"
    mime ^text, label pager = "$PAGER" -- "$@"
    !mime ^text, label editor, ext xml|json|csv|tex|py|pl|rb|js|sh|php = "$EDITOR" -- "$@"
    !mime ^text, label pager, ext xml|json|csv|tex|py|pl|rb|js|sh|php = "$PAGER" -- "$@"
    
    # Misc files
    ext 1 = man "$1"
    ext exe = wine "$1"
    ext msi = wine "$1"
    name ^[mM]akefile$ = make
    
    # Scripts
    ext py = python -- "$1"
    ext pl = perl -- "$1"
    ext rb = ruby -- "$1"
    ext js = node -- "$1"
    ext sh = sh -- "$1"
    ext php = php -- "$1"
    
    # Audio and video
    mime ^audio|ogg$, terminal, has mpv = mpv --no-audio-display -- "$@"
    mime ^audio|ogg$, terminal, has mpv = mpv --shuffle --no-audio-display -- "$@"
    mime ^video, has mpv, X, flag f = mpv -- "$@"
    mime ^video, terminal, !X, has mpv = mpv -- "$@"
    
    # Documents
    ext pdf, has zathura, X, flag f = zathura -- "$@"
    ext pdf, has xpdf, X, flag f = xpdf -- "$@"
    ext pdf, has okular, X, flag f = okular -- "$@"
    ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has libreoffice, X, flag f = libreoffice "$@"
    
    # Images
    mime ^image/gif, has mpv, X, flag f = mpv -- "$@"
    mime ^image, has imv, X, flag f = imv -- "$@"
    
    # Archives
    ext 7z, has 7z = 7z -p l "$@" | "$PAGER"
    ext 7z|ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz, has 7z = 7z x -- "$@"
    ext iso|jar|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip, has 7z = 7z x -- "$@"
    
    # Listing and extracting archives without atool:
    ext tar|gz|bz2|xz, has tar = tar vvtf "$1" | "$PAGER"
    ext tar|gz|bz2|xz, has tar = for file in "$@"; do tar vvxf "$file"; done
    
    # Fonts
    mime ^font, has fontforge, X, flag f = fontforge "$@"
    
    # Flag fallback terminals
    mime ^ranger/x-terminal-emulator, has kitty = kitty -- "$@"
    
    # Generic file openers
    label open, has xdg-open = xdg-open -- "$@"
    
    # Define the editor for non-text files + pager as last action
    !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php = ask
    label editor, !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php = "$EDITOR" -- "$@"
    label pager, !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php = "$PAGER" -- "$@"
    
    # Execute a file as program/script.
    mime application/x-executable = "$1"
  '';

  # Ranger's preview
  scopesh = ''
    #!/usr/bin/env bash
    set -o noclobber -o noglob -o nounset -o pipefail
    IFS=$'\n'
    
    # Script arguments
    FILE_PATH="$1"
    PV_WIDTH="$2"
    PV_HEIGHT="$3"
    IMAGE_CACHE_PATH="$4"
    PV_IMAGE_ENABLED="$5"
    
    FILE_EXTENSION=$(echo "$FILE_PATH" | rev | cut -d. -f1 | rev)
    FILE_EXTENSION_LOWER=$(echo "$FILE_EXTENSION" | tr '[:upper:]' '[:lower:]')
    
    # Settings
    HIGHLIGHT_TABWIDTH=8
    HIGHLIGHT_STYLE='pablo'
    PYGMENTIZE_STYLE='autumn'
    
    handle_extension() {
      case "$FILE_EXTENSION_LOWER" in
        # Archive
        a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
        rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
          atool --list -- "$FILE_PATH" && exit 5
          bsdtar --list --file "$FILE_PATH" && exit 5
          exit 1;;
        rar)
          unrar lt -p- -- "$FILE_PATH" && exit 5
          exit 1;;
        7z)
          7z l -p -- "$FILE_PATH" && exit 5
          exit 1;;
        pdf)
          pdftotext -l 10 -nopgbrk -q -- "$FILE_PATH" - && exit 5
          exiftool "$FILE_PATH" && exit 5
          exit 1;;
        torrent)
          transmission-show -- "$FILE_PATH" && exit 5
          exit 1;;
        # OpenDocument
        odt|ods|odp|sxw)
          odt2txt "$FILE_PATH" && exit 5
          exit 1;;
        # HTML
        htm|html|xhtml)
          w3m -dump "$FILE_PATH" && exit 5
          lynx -dump -- "$FILE_PATH" && exit 5
          ;; # Continue with next handler on failure
      esac
    }
    
    handle_image() {
      local mimetype="$1"
      case "$mimetype" in
        # SVG
        image/svg+xml)
          convert "$FILE_PATH" "$IMAGE_CACHE_PATH" && exit 6
          exit 1;;
        # Image
        image/*)
          local orientation
          orientation="$( identify -format '%[EXIF:Orientation]\n' -- "$FILE_PATH" )"
          if [[ -n "$orientation" && "$orientation" != 1 ]]; then
              convert -- "$FILE_PATH" -auto-orient "$IMAGE_CACHE_PATH" && exit 6
          fi
          exit 7;;
        # Video
        video/*)
          # Thumbnail
          ffmpegthumbnailer -i "$FILE_PATH" -o "$IMAGE_CACHE_PATH" -s 0 && exit 6
          exit 1;;
        # PDF
        application/pdf)
          pdftoppm -f 1 -l 1 \
            -scale-to-x 1920 \
            -scale-to-y -1 \
            -singlefile \
            -jpeg -tiffcompression jpeg \
            -- "$FILE_PATH" "$(basename "$IMAGE_CACHE_PATH")" \
          && exit 6 || exit 1;;
      esac
    }
    
    handle_mime() {
      local mimetype="$1"
      case "$mimetype" in
        # Text
        text/* | */xml)
          exit 2;;
        # Image
        image/*)
          exiftool "$FILE_PATH" && exit 5
          exit 1;;
        # Video and audio
        video/* | audio/*)
          mediainfo "$FILE_PATH" && exit 5
          exiftool "$FILE_PATH" && exit 5
          exit 1;;
      esac
    }
    
    MIMETYPE="$( file --dereference --brief --mime-type -- "$FILE_PATH" )"
    if [[ "$PV_IMAGE_ENABLED" == 'True' ]]; then
      handle_image "$MIMETYPE"
    fi
    handle_extension
    handle_mime "$MIMETYPE"
    handle_fallback
    exit 1
  '';

  # Rofi icons initialization
  iconinit = ''
    import ranger.api
    from ranger.core.linemode import LinemodeBase
    from .devicons import *
    
    @ranger.api.register_linemode
    class DevIconsLinemode(LinemodeBase):
      name = "devicons"
    
      uses_metadata = False
    
      def filetitle(self, file, metadata):
        return devicon(file) + ' ' + file.relative_path
    
    @ranger.api.register_linemode
    class DevIconsLinemodeFile(LinemodeBase):
      name = "filename"
    
      def filetitle(self, file, metadata):
        return devicon(file) + ' ' + file.relative_path
  '';

  # The actual icons. I don't like how long this file is
  rangericons = ''
    #!/usr/bin/python
    # https://github.com/ryanoasis/vim-devicons
    import re, os;
    
    # Glyphs will show up as corrupted squares if not using a patched nerd-font.
    file_node_extensions = {
      '7z'       : '',
      'a'        : '',
      'ai'       : '',
      'apk'      : '',
      'asm'      : '',
      'asp'      : '',
      'aup'      : '',
      'avi'      : '',
      'awk'      : '',
      'bash'     : '',
      'bat'      : '',
      'bmp'      : '',
      'bz2'      : '',
      'c'        : '',
      'c++'      : '',
      'cab'      : '',
      'cbr'      : '',
      'cbz'      : '',
      'cc'       : '',
      'class'    : '',
      'clj'      : '',
      'cljc'     : '',
      'cljs'     : '',
      'cmake'    : '',
      'coffee'   : '',
      'conf'     : '',
      'cp'       : '',
      'cpio'     : '',
      'cpp'      : '',
      'cs'       : '',
      'csh'      : '',
      'css'      : '',
      'cue'      : '',
      'cvs'      : '',
      'cxx'      : '',
      'd'        : '',
      'dart'     : '',
      'db'       : '',
      'deb'      : '',
      'diff'     : '',
      'dll'      : '',
      'doc'      : '',
      'docx'     : '',
      'dump'     : '',
      'edn'      : '',
      'eex'      : '',
      'efi'      : '',
      'ejs'      : '',
      'elf'      : '',
      'elm'      : '',
      'epub'     : '',
      'erl'      : '',
      'ex'       : '',
      'exe'      : '',
      'exs'      : '',
      'f#'       : '',
      'fifo'     : '|',
      'fish'     : '',
      'flac'     : '',
      'flv'      : '',
      'fs'       : '',
      'fsi'      : '',
      'fsscript' : '',
      'fsx'      : '',
      'gem'      : '',
      'gemspec'  : '',
      'gif'      : '',
      'go'       : '',
      'gz'       : '',
      'gzip'     : '',
      'h'        : '',
      'haml'     : '',
      'hbs'      : '',
      'hh'       : '',
      'hpp'      : '',
      'hrl'      : '',
      'hs'       : '',
      'htaccess' : '',
      'htm'      : '',
      'html'     : '',
      'htpasswd' : '',
      'hxx'      : '',
      'ico'      : '',
      'img'      : '',
      'ini'      : '',
      'iso'      : '',
      'jar'      : '',
      'java'     : '',
      'jl'       : '',
      'jpeg'     : '',
      'jpg'      : '',
      'js'       : '',
      'json'     : '',
      'jsx'      : '',
      'key'      : '',
      'ksh'      : '',
      'leex'     : '',
      'less'     : '',
      'lha'      : '',
      'lhs'      : '',
      'log'      : '',
      'lua'      : '',
      'lzh'      : '',
      'lzma'     : '',
      'm4a'      : '',
      'm4v'      : '',
      'markdown' : '',
      'md'       : '',
      'mdx'      : '',
      'mjs'      : '',
      'mkv'      : '',
      'ml'       : 'λ',
      'mli'      : 'λ',
      'mov'      : '',
      'mp3'      : '',
      'mp4'      : '',
      'mpeg'     : '',
      'mpg'      : '',
      'msi'      : '',
      'mustache' : '',
      'nix'      : '',
      'o'        : '',
      'ogg'      : '',
      'pdf'      : '',
      'php'      : '',
      'pl'       : '',
      'pm'       : '',
      'png'      : '',
      'pp'       : '',
      'ppt'      : '',
      'pptx'     : '',
      'ps1'      : '',
      'psb'      : '',
      'psd'      : '',
      'pub'      : '',
      'py'       : '',
      'pyc'      : '',
      'pyd'      : '',
      'pyo'      : '',
      'r'        : 'ﳒ',
      'rake'     : '',
      'rar'      : '',
      'rb'       : '',
      'rc'       : '',
      'rlib'     : '',
      'rmd'      : '',
      'rom'      : '',
      'rpm'      : '',
      'rs'       : '',
      'rss'      : '',
      'rtf'      : '',
      's'        : '',
      'sass'     : '',
      'scala'    : '',
      'scss'     : '',
      'sh'       : '',
      'slim'     : '',
      'sln'      : '',
      'so'       : '',
      'sql'      : '',
      'styl'     : '',
      'suo'      : '',
      'swift'    : '',
      't'        : '',
      'tar'      : '',
      'tex'      : 'ﭨ',
      'tgz'      : '',
      'toml'     : '',
      'ts'       : '',
      'tsx'      : '',
      'twig'     : '',
      'vim'      : '',
      'vimrc'    : '',
      'wav'      : '',
      'webm'     : '',
      'webmanifest' : '',
      'webp'     : '',
      'xbps'     : '',
      'xhtml'    : '',
      'xls'      : '',
      'xlsx'     : '',
      'xml'      : '',
      'xul'      : '',
      'xz'       : '',
      'yaml'     : '',
      'yml'      : '',
      'zip'      : '',
      'zsh'      : '',
    }
    
    dir_node_exact_matches = {
    # English
      '.git'             : '',
      'Desktop'          : '',
      'Documents'        : '',
      'Downloads'        : '',
      'Dotfiles'         : '',
      'Dropbox'          : '',
      'Music'            : '',
      'Pictures'         : '',
      'Public'           : '',
      'Templates'        : '',
      'Videos'           : '',
    # Spanish
      'Escritorio'       : '',
      'Documentos'       : '',
      'Descargas'        : '',
      'Música'           : '',
      'Imágenes'         : '',
      'Público'          : '',
      'Plantillas'       : '',
      'Vídeos'           : '',
    # French
      'Bureau'           : '',
      'Documents'        : '',
      'Images'           : '',
      'Musique'          : '',
      'Publique'         : '',
      'Téléchargements'  : '',
      'Vidéos'           : '',
    # Italian
      'Documenti'        : '',
      'Immagini'         : '',
      'Modelli'          : '',
      'Musica'           : '',
      'Pubblici'         : '',
      'Scaricati'        : '',
      'Scrivania'        : '',
      'Video'            : '',
    # German
      'Bilder'           : '',
      'Dokumente'        : '',
      'Musik'            : '',
      'Schreibtisch'     : '',
      'Vorlagen'         : '',
      'Öffentlich'       : '',
    }
    
    file_node_exact_matches = {
      '.bash_aliases'                    : '',
      '.bash_history'                    : '',
      '.bash_logout'                     : '',
      '.bash_profile'                    : '',
      '.bashprofile'                     : '',
      '.bashrc'                          : '',
      '.dmrc'                            : '',
      '.DS_Store'                        : '',
      '.fasd'                            : '',
      '.fehbg'                           : '',
      '.gitattributes'                   : '',
      '.gitconfig'                       : '',
      '.gitignore'                       : '',
      '.gitlab-ci.yml'                   : '',
      '.gvimrc'                          : '',
      '.inputrc'                         : '',
      '.jack-settings'                   : '',
      '.mime.types'                      : '',
      '.ncmpcpp'                         : '',
      '.nvidia-settings-rc'              : '',
      '.pam_environment'                 : '',
      '.profile'                         : '',
      '.recently-used'                   : '',
      '.selected_editor'                 : '',
      '.vim'                             : '',
      '.viminfo'                         : '',
      '.vimrc'                           : '',
      '.Xauthority'                      : '',
      '.Xdefaults'                       : '',
      '.xinitrc'                         : '',
      '.xinputrc'                        : '',
      '.Xresources'                      : '',
      '.zshrc'                           : '',
      '_gvimrc'                          : '',
      '_vimrc'                           : '',
      'a.out'                            : '',
      'authorized_keys'                  : '',
      'bspwmrc'                          : '',
      'cmakelists.txt'                   : '',
      'config'                           : '',
      'config.ac'                        : '',
      'config.m4'                        : '',
      'config.mk'                        : '',
      'config.ru'                        : '',
      'configure'                        : '',
      'docker-compose.yml'               : '',
      'dockerfile'                       : '',
      'Dockerfile'                       : '',
      'dropbox'                          : '',
      'exact-match-case-sensitive-1.txt' : 'X1',
      'exact-match-case-sensitive-2'     : 'X2',
      'favicon.ico'                      : '',
      'gemfile'                          : '',
      'gruntfile.coffee'                 : '',
      'gruntfile.js'                     : '',
      'gruntfile.ls'                     : '',
      'gulpfile.coffee'                  : '',
      'gulpfile.js'                      : '',
      'gulpfile.ls'                      : '',
      'ini'                              : '',
      'known_hosts'                      : '',
      'ledger'                           : '',
      'license'                          : '',
      'LICENSE'                          : '',
      'LICENSE.md'                       : '',
      'LICENSE.txt'                      : '',
      'Makefile'                         : '',
      'makefile'                         : '',
      'Makefile.ac'                      : '',
      'Makefile.in'                      : '',
      'mimeapps.list'                    : '',
      'mix.lock'                         : '',
      'node_modules'                     : '',
      'package-lock.json'                : '',
      'package.json'                     : '',
      'playlists'                        : '',
      'procfile'                         : '',
      'Rakefile'                         : '',
      'rakefile'                         : '',
      'react.jsx'                        : '',
      'README'                           : '',
      'README.markdown'                  : '',
      'README.md'                        : '',
      'README.rst'                       : '',
      'README.txt'                       : '',
      'sxhkdrc'                          : '',
      'user-dirs.dirs'                   : '',
      'webpack.config.js'                : '',
    }
    
    def devicon(file):
      if file.is_directory: return dir_node_exact_matches.get(file.relative_path, '')
      return file_node_exact_matches.get(os.path.basename(file.relative_path), file_node_extensions.get(file.extension, ''))
  '';

  # Rofi launcher main config
  roficonf = ''
    @theme "~/.config/rofi/purple.rasi"
  '';

  # Rofi's theme
  rofitheme = ''
    * {
      selected-normal-foreground:  #FFFFFF;
      foreground:                  #${textcolor};
      normal-foreground:           #${textcolor};
      alternate-normal-foreground: #${textcolor};
      normal-background:           #${darkcol}1A;
      alternate-normal-background: #${darkcol}1A;
      blue:                        #268BD2;
      red:                         #DC322F;
      selected-urgent-foreground:  #${urgentcol};
      urgent-foreground:           #${urgentcol};
      alternate-urgent-foreground: @urgent-foreground;
      alternate-urgent-background: #${accentcol}80;
      alternate-active-background: #${accentcol}80;
      active-foreground:           #${splitcol};
      lightbg:                     #EEE8D5;
      selected-active-foreground:  #${primecol};
      background:                  #${darkcol}B3;
      bordercolor:                 #${primecol};
      lightfg:                     #586875;
      selected-normal-background:  #${primecol}80;
      border-color:                #${primecol};
      spacing:                     2;
      urgent-background:           #${accentcol}26;
      selected-urgent-background:  #${splitcol}54;
      background-color:            #00000000;
      separatorcolor:              #00000000;
      alternate-active-foreground: @active-foreground;
      active-background:           #${accentcol}26;
      selected-active-background:  #${splitcol}54;
    }
    window {
      background-color: @background;
      width: 500px;
      transparency:     "real";
      border:           2;
      padding:          5;
    }
    mainbox {
      border:  0;
      padding: 0;
    }
    message {
      border:       1px dash 0px 0px ;
      border-color: @separatorcolor;
      padding:      1px ;
    }
    textbox {
      text-color: @foreground;
    }
    listview {
      fixed-height: 0;
      border-color: @separatorcolor;
      scrollbar:    false;
      padding:      2px 0px 0px ;
      columns: 2;
    }
    element {
      border:  0;
      padding: 1px ;
    }
    element-text {
      background-color: inherit;
      text-color:       inherit;
    }
    element.normal.normal {
      text-color:       @normal-foreground;
    }
    element.normal.urgent {
      text-color:       @urgent-foreground;
    }
    element.normal.active {
      background-color: @active-background;
      text-color:       @active-foreground;
    }
    element.selected.normal {
      background-color: @selected-normal-background;
      text-color:       @selected-normal-foreground;
    }
    element.selected.urgent {
      background-color: @selected-urgent-background;
      text-color:       @selected-urgent-foreground;
    }
    element.selected.active {
      background-color: @selected-active-background;
      text-color:       @selected-active-foreground;
    }
    element.alternate.normal {
      text-color:       @alternate-normal-foreground;
    }
    element.alternate.urgent {
      text-color:       @alternate-urgent-foreground;
    }
    element.alternate.active {
      background-color: @alternate-active-background;
      text-color:       @alternate-active-foreground;
    }
    mode-switcher {
      border:       2px dash 0px 0px ;
      border-color: @separatorcolor;
    }
    button.selected {
      background-color: @selected-normal-background;
      text-color:       @selected-normal-foreground;
    }
    inputbar {
      spacing:    0;
      text-color: @normal-foreground;
      padding:    1px ;
    }
    case-indicator {
      spacing:    0;
      text-color: @normal-foreground;
    }
    entry {
      spacing:    0;
      text-color: @normal-foreground;
    }
    prompt {
      spacing:    0;
      text-color: @normal-foreground;
    }
    inputbar {
      children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
    }
    textbox-prompt-colon {
      expand:     false;
      str:        ":";
      margin:     0px 0.3em 0em 0em ;
      text-color: @normal-foreground;
    }
  '';

  # Sunshine apps config
  sunshineapps = ''
    {
      "env": {
        "PATH": "$(PATH):$(HOME)\/.local\/bin"
      },
      "apps": [
        {
          "name": "Desktop",
          "image-path": "desktop.png"
        }
      ]
    }
  '';

  # ytfzf config
  ytfzfconf = ''
    external_menu () {
      bemenu --fn "Ubuntu 13" --nb "#${darkcol}" --ab "#${darkcol}" --tb "#${primecol}" --fb "#${darkcol}" --tf "#ffffff" --hf "#ffffff" --hb "#${primecol}" -l 30 -s -p "Search:"
    }
    
    video_player () {
      mpv --loop-playlist=no --keep-open=yes "$@"
    }
  '';

  # Some sound settings use alsoft, which needs to be configured to use pipewire
  alsoftrc = ''
    drivers=pulse
  '';

  # FireFox/LibreWolf colors
  personalcolors = ''
    /* SimpleFox by Miguel Avila */

    /* Main config */
    :root {
      /* Colors */
      --window-colour:               #${darkcol};
      --secondary-colour:            #${primecol};
      --inverted-colour:             #FAFAFC;
    }
  '';
  workcolors = ''
    /* SimpleFox by Miguel Avila */

    /* Main config */
    :root {
      /* Colors */
      --window-colour:               #${primecol};
      --secondary-colour:            #${darkcol};
      --inverted-colour:             #FAFAFC;
    }
  '';
  simplefox = ''
    :root {
      /* Containter Tab Colours */
      --uc-identity-color-blue:      #7ED6DF;
      --uc-identity-color-turquoise: #55E6C1;
      --uc-identity-color-green:     #B8E994;
      --uc-identity-color-yellow:    #F7D794;
      --uc-identity-color-orange:    #F19066;
      --uc-identity-color-red:       #FC5C65;
      --uc-identity-color-pink:      #F78FB3;
      --uc-identity-color-purple:    #786FA6;
      
      /* URL colour in URL bar suggestions */
      --urlbar-popup-url-color: var(--window-colour) !important;
       
      /* Visuals */
      
      /* global border radius */
      --uc-border-radius: 0;
       
      /* dynamic url bar width settings */
      --uc-urlbar-width: clamp(200px, 40vw, 500px);
    
      /* dynamic tab width settings */
      --uc-active-tab-width:   clamp(100px, 20vw, 300px);
      --uc-inactive-tab-width: clamp( 50px, 15vw, 200px);
    
      /* if active always shows the tab close button */
      --show-tab-close-button: none; /* DEFAULT: -moz-inline-box; */ 
    
      /* if active only shows the tab close button on hover*/
      --show-tab-close-button-hover: none; /* DEFAULT: -moz-inline-box; */
       
      /* adds left and right margin to the container-tabs indicator */
      --container-tabs-indicator-margin: 10px;
    }
    
    /* Buttons */
    
    #back-button,
    #forward-button { display: none !important; }
    
    /* bookmark icon */
    #star-button{ display: none !important; }
    
    /* zoom indicator */
    #urlbar-zoom-button { display: none !important; }
    
    /* hides context burger menu BUT causes popups to be buggy at times */
    #PanelUI-button { display: none !important; }
    
    #reader-mode-button{ display: none !important; }
    
    /* tracking protection shield icon */
    #tracking-protection-icon-container { display: none !important; }
    
    /* #identity-box { display: none !important } /* hides encryption AND permission items */
    #identity-permission-box { display: none !important; } /* only hodes permission items */
    
    /* e.g. playing indicator (secondary - not icon) */
    .tab-secondary-label { display: none !important; }
    
    #pageActionButton { display: none !important; }
    #page-action-buttons { display: none !important; }
    
    /* Layout */
    :root {
      --uc-theme-colour:                          var(--window-colour);
      --uc-hover-colour:                          var(--secondary-colour);
      --uc-inverted-colour:                       var(--inverted-colour);
      
      --button-bgcolor:                           var(--uc-theme-colour)    !important;
      --button-hover-bgcolor:                     var(--uc-hover-colour)    !important;
      --button-active-bgcolor:                    var(--uc-hover-colour)    !important;
      
      --toolbar-bgcolor:                          var(--uc-theme-colour)    !important;
      --toolbarbutton-hover-background:           var(--uc-hover-colour)    !important;
      --toolbarbutton-active-background:          var(--uc-hover-colour)    !important;
      --toolbarbutton-border-radius:              var(--uc-border-radius)   !important;
      --lwt-toolbar-field-focus:                  var(--uc-theme-colour)    !important;
      --toolbarbutton-icon-fill:                  var(--uc-inverted-colour) !important;
      --toolbar-field-focus-background-color:     var(--uc-inverted-colour)   !important;
      --toolbar-field-color:                      var(--uc-inverted-colour) !important;
      --toolbar-field-focus-color:                var(--uc-inverted-colour) !important;
      
      --tabs-border-color:                        var(--uc-theme-colour)    !important;
      --tab-border-radius:                        var(--uc-border-radius)   !important;
      --lwt-text-color:                           var(--uc-inverted-colour) !important;
      --lwt-tab-text:                             var(--uc-inverted-colour) !important;
    
      --lwt-sidebar-background-color:             var(--uc-hover-colour)    !important;
      --lwt-sidebar-text-color:                   var(--uc-inverted-colour) !important;
    
      --arrowpanel-border-color:                  var(--uc-theme-colour)    !important;
      --arrowpanel-border-radius:                 var(--uc-border-radius)   !important;
      --arrowpanel-background:                    var(--uc-theme-colour)    !important;
      --arrowpanel-color:                         var(--inverted-colour)    !important;
    
      --autocomplete-popup-highlight-background:  var(--uc-inverted-colour) !important;
      --autocomplete-popup-highlight-color:       var(--uc-inverted-colour) !important;
      --autocomplete-popup-hover-background:      var(--uc-inverted-colour) !important;
      
      --tab-block-margin: 0px !important;
    }
    
    window,
    #main-window,
    #toolbar-menubar,
    #TabsToolbar,
    #PersonalToolbar,
    #navigator-toolbox,
    #sidebar-box,
    #nav-bar {
      -moz-appearance: none !important;
      border: none !important;
      box-shadow: none !important;
      background: var(--uc-theme-colour) !important;
    }
    
    /* grey out icons inside the toolbar to align with the Black & White colour look */
    #PersonalToolbar toolbarbutton:not(:hover),
    #bookmarks-toolbar-button:not(:hover) { filter: grayscale(1) !important; }
    
    /* remove window control buttons */
    .titlebar-buttonbox-container { display: none !important; }
    
    /* remove "padding" left and right from tabs */
    .titlebar-spacer { display: none !important; }
    
    /* remove gap after pinned tabs */
    #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs])
      > #tabbrowser-arrowscrollbox
      > .tabbrowser-tab[first-visible-unpinned-tab] { margin-inline-start: 0 !important; }
    
    /* remove tab shadow */
    .tabbrowser-tab
      >.tab-stack
      > .tab-background { box-shadow: none !important;  }
    
    /* tab background */
    .tabbrowser-tab
      > .tab-stack
      > .tab-background { background: var(--uc-theme-colour) !important; }
    
    /* active tab background */
    .tabbrowser-tab[selected]
      > .tab-stack
      > .tab-background { background: var(--uc-hover-colour) !important; }
    
    /* tab close button options */
    .tabbrowser-tab:not([pinned]) .tab-close-button { display: var(--show-tab-close-button) !important; }
    .tabbrowser-tab:not([pinned]):hover .tab-close-button { display: var(--show-tab-close-button-hover) !important }
    
    /* adaptive tab width */
    .tabbrowser-tab[selected][fadein]:not([pinned]) { max-width: var(--uc-active-tab-width) !important; }
    .tabbrowser-tab[fadein]:not([selected]):not([pinned]) { max-width: var(--uc-inactive-tab-width) !important; }
    
    /* container tabs indicator */
    .tabbrowser-tab[usercontextid]
      > .tab-stack
      > .tab-background
      > .tab-context-line {
        margin: -1px var(--container-tabs-indicator-margin) 0 var(--container-tabs-indicator-margin) !important;
        border-radius: var(--tab-border-radius) !important;
      }
    
    /* show favicon when media is playing but tab is hovered */
    .tab-icon-image:not([pinned]) { opacity: 1 !important; }
    
    /* Makes the speaker icon to always appear if the tab is playing (not only on hover) */
    .tab-icon-overlay:not([crashed]),
    .tab-icon-overlay[pinned][crashed][selected] {
      top: 5px !important;
      z-index: 1 !important;
      padding: 1.5px !important;
      inset-inline-end: -8px !important;
      width: 16px !important; height: 16px !important;
      border-radius: 10px !important;
    }
    
    /* style and position speaker icon */
    .tab-icon-overlay:not([sharing], [crashed]):is([soundplaying], [muted], [activemedia-blocked]) {
      stroke: transparent !important;
      background: transparent !important;
      opacity: 1 !important; fill-opacity: 0.8 !important;
      color: currentColor !important;
      stroke: var(--uc-theme-colour) !important;
      background-color: var(--uc-theme-colour) !important;
    }
    
    /* change the colours of the speaker icon on active tab to match tab colours */
    .tabbrowser-tab[selected] .tab-icon-overlay:not([sharing], [crashed]):is([soundplaying], [muted], [activemedia-blocked]) {
      stroke: var(--uc-hover-colour) !important;
      background-color: var(--uc-hover-colour) !important;
    }
    
    .tab-icon-overlay:not([pinned], [sharing], [crashed]):is([soundplaying], [muted], [activemedia-blocked]) { margin-inline-end: 9.5px !important; }
    .tabbrowser-tab:not([image]) .tab-icon-overlay:not([pinned], [sharing], [crashed]) {
      top: 0 !important;
      padding: 0 !important;
      margin-inline-end: 5.5px !important; 
      inset-inline-end: 0 !important;
    }
    
    .tab-icon-overlay:not([crashed])[soundplaying]:hover,
    .tab-icon-overlay:not([crashed])[muted]:hover,
    .tab-icon-overlay:not([crashed])[activemedia-blocked]:hover {
      color: currentColor !important;
      stroke: var(--uc-inverted-colour) !important;
      background-color: var(--uc-inverted-colour) !important;
      fill-opacity: 0.95 !important;
    }
    
    .tabbrowser-tab[selected] .tab-icon-overlay:not([crashed])[soundplaying]:hover,
    .tabbrowser-tab[selected] .tab-icon-overlay:not([crashed])[muted]:hover,
    .tabbrowser-tab[selected] .tab-icon-overlay:not([crashed])[activemedia-blocked]:hover {
      color: currentColor !important;
      stroke: var(--uc-inverted-colour) !important;
      background-color: var(--uc-inverted-colour) !important;
      fill-opacity: 0.95 !important;
    }
    
    /* speaker icon colour fix */
    #TabsToolbar .tab-icon-overlay:not([crashed])[soundplaying],
    #TabsToolbar .tab-icon-overlay:not([crashed])[muted],
    #TabsToolbar .tab-icon-overlay:not([crashed])[activemedia-blocked] { color: var(--uc-inverted-colour) !important; }
    
    /* speaker icon colour fix on hover */
    #TabsToolbar .tab-icon-overlay:not([crashed])[soundplaying]:hover,
    #TabsToolbar .tab-icon-overlay:not([crashed])[muted]:hover,
    #TabsToolbar .tab-icon-overlay:not([crashed])[activemedia-blocked]:hover { color: var(--uc-theme-colour) !important; }
    
    #nav-bar {
      border:     none !important;
      box-shadow: none !important;
      background: transparent !important;
    }
    
    /* remove border below whole nav */
    #navigator-toolbox { border-bottom: none !important; }
    #urlbar,
    #urlbar * {
      outline: none !important;
      box-shadow: none !important;
    }
    
    #urlbar-background { border: var(--uc-hover-colour) !important; }
    
    #urlbar[focused="true"]
        > #urlbar-background,
    #urlbar:not([open])
        > #urlbar-background { background: transparent !important; }
    
    #urlbar[open]
        > #urlbar-background { background: var(--uc-theme-colour) !important; }
    
    .urlbarView-row:hover
        > .urlbarView-row-inner,
    .urlbarView-row[selected]
        > .urlbarView-row-inner { background: var(--uc-hover-colour) !important; }
    
    /* transition to oneline */
    @media (min-width: 1000px) { 
      /* move tabs bar over */
      #TabsToolbar { margin-left: var(--uc-urlbar-width) !important; }
    
      /* move entire nav bar  */
      #nav-bar { margin: calc((var(--urlbar-min-height) * -1) - 8px) calc(100vw - var(--uc-urlbar-width)) 0 0 !important; }
    } /* end media query */
    
    /* Container Tabs */
    .identity-color-blue      { --identity-tab-color: var(--uc-identity-color-blue)      !important; --identity-icon-color: var(--uc-identity-color-blue)      !important; }
    .identity-color-turquoise { --identity-tab-color: var(--uc-identity-color-turquoise) !important; --identity-icon-color: var(--uc-identity-color-turquoise) !important; }
    .identity-color-green     { --identity-tab-color: var(--uc-identity-color-green)     !important; --identity-icon-color: var(--uc-identity-color-green)     !important; }
    .identity-color-yellow    { --identity-tab-color: var(--uc-identity-color-yellow)    !important; --identity-icon-color: var(--uc-identity-color-yellow)    !important; }
    .identity-color-orange    { --identity-tab-color: var(--uc-identity-color-orange)    !important; --identity-icon-color: var(--uc-identity-color-orange)    !important; }
    .identity-color-red       { --identity-tab-color: var(--uc-identity-color-red)       !important; --identity-icon-color: var(--uc-identity-color-red)       !important; }
    .identity-color-pink      { --identity-tab-color: var(--uc-identity-color-pink)      !important; --identity-icon-color: var(--uc-identity-color-pink)      !important; }
    .identity-color-purple    { --identity-tab-color: var(--uc-identity-color-purple)    !important; --identity-icon-color: var(--uc-identity-color-purple)    !important; }
    .tab-label-container{ height: unset !important; }
  '';
  simplefoxcontent = ''
    /* SimpleFox by Miguel Avila */

    :root {
      scrollbar-width: none !important;
    }
    
    @-moz-document url(about:privatebrowsing) {
      :root {
        scrollbar-width: none !important;
      }
    }
  '';
  foxinstalls = ''
    [4F96D1932A9F858E]
    Default=Jimbo
    Locked=1
    
    [C783E445CF9CA815]
    Default=Jimbo
    Locked=1
    
    [6C1CE26D3274EA5B]
    Default=Jimbo
    Locked=1
  '';
  foxprofiles = ''
    [Profile0]
    Name=Jimbo
    IsRelative=1
    Path=Jimbo
    Default=1
    
    [Profile1]
    Name=School
    IsRelative=1
    Path=School
    
    [Profile2]
    Name=Variety
    IsRelative=1
    Path=Variety

    [General]
    StartWithLastProfile=1
    Version=2
  '';
  foxuserjs = ''
    // Enable Compact Mode
    user_pref("browser.uidensity", 1);
  '';
in

{
  # Define home manager programs and configs
  home-manager = {
    useGlobalPkgs = true;
    users.jimbo = { config, pkgs, ... }: {
      # Install user programs
      home.packages = with pkgs; [
        # Sway/Desktop
        swayfx swaybg swayidle swaylock-effects wlroots_0_16 wdisplays wl-clipboard 
	clipman bemenu waybar xwayland libnotify swappy bc grim slurp 
	jq imagemagick libsForQt5.qtstyleplugins lm_sensors

        # Useful programs
        home-manager ffmpegthumbnailer imv kitty kittydash rofi-wayland bemoji dua p7zip
	qbittorrent neofetch libreoffice-fresh easyeffects pavucontrol gotop man pciutils

        # File manager
        lxqt.pcmanfm-qt gnome.file-roller ranger poppler_utils

        # Audio/Video tools
        yt-dlp ytfzf ani-cli playerctl ffmpeg

        # Production tools
        krita libsForQt5.kdenlive audacity

        # Unlimited games
        steam heroic mangohud sunshine winePackages.wayland
	runelite minetest prismlauncher 

        # Emulators
        dolphin-emu duckstation pcsx2 rpcs3

        # School tools
        remmina freerdp libvncserver globalprotect-openconnect zoom-us
      ];

      # Start defining GTK theme settings
      gtk = {
        enable = true;
	font = {
          name = "Ubuntu";
          size = 11;
	};
        theme = {
	  package = pkgs.colloid-gtk-theme.override {
	    themeVariants = [ "purple" ];
	    colorVariants = [ "dark" ];
	    sizeVariants = [ "standard" ];
	    tweaks = [ "${themetweak}" "rimless" "normal" ];
	  };
	  name = "${theme}";
        };
        iconTheme = {
	  package = pkgs.papirus-icon-theme.override {
	    color = "${foldercol}";
          };
	  name = "Papirus-Dark";
	};
        cursorTheme = {
          package = pkgs.simp1e-cursors;
          name = "Simp1e-Dark";
        };

	# GTK app bookmarks
	gtk3.bookmarks = [
	  "file:///home/jimbo/JimboSMB/JimboOS"
	  "file:///home/jimbo/Downloads"
          "file:///home/jimbo/JimboSMB/Downloads"
          "file:///home/jimbo/JimboSMB/Documents"
          "file:///home/jimbo/JimboSMB/Music"
          "file:///home/jimbo/JimboSMB/Photos"
          "file:///home/jimbo/JimboSMB/Videos"
          "file:///home/jimbo/JimboSMB/Minecraft%20Servers"
          "file:///home/jimbo/VMs"
          "file:///home/jimbo/Mounts"
          "file:///home/jimbo/Games"
          "file:///home/jimbo/JimboSMB/School"
          "file:///home/jimbo/JimboSMB/JimboOS/RootBase"
	];

	# Stop gtk4 from being rounded
	gtk4.extraCss = ''
          window {
            border-top-left-radius:0;
            border-top-right-radius:0;
            border-bottom-left-radius:0;
            border-bottom-right-radius:0;
          }
        '';
      };

      # Install LibreWolf with settings
      programs.librewolf = {
        enable = true;
	settings = {
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "network.cookie.lifetimePolicy" = 0;
	  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
	  "browser.compactmode.show" = true;
	  "browser.toolbars.bookmarks.visibility" = "newtab";
	  "gnomeTheme.hideSingleTab" = true;
	  "svg.context-properties.content.enabled" = true;
        };
      };

      # Install Neovim and plugins
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          vim-airline
          vim-airline-themes
          vim-vsnip
          cmp-vsnip
          nvim-lspconfig
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
          nvim-cmp
          nerdtree
          lspkind-nvim
          nvim-colorizer-lua
	  vim-monokai-pro
        ];
        extraConfig = ''
          lua <<EOF
          -- Set up nvim-cmp.
          local cmp = require'cmp'
          
          cmp.setup({
            snippet = {
              -- REQUIRED - you must specify a snippet engine
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'vsnip' }
            }, {
              { name = 'buffer' },
            })
          })
          
          -- Set configuration for specific filetype.
          cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({
              { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
            }, {
              { name = 'buffer' },
            })
          })
          
          -- Use buffer source for `/` and `?`.
          cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
              { name = 'buffer' }
            }
          })
          
          -- Use cmdline & path source for ':'.
          cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
              { name = 'path' }
            }, {
              { name = 'cmdline' }
            })
          })
          EOF
          
          nmap <C-a> :NERDTreeToggle<CR>
          
          colorscheme monokai_pro
          let g:airline_theme='onedark'
          let g:airline#extensions#tabline#enabled = 1
          highlight Normal guibg=#${darkcol} ctermbg=235
          highlight Visual guibg=#151515 ctermbg=238
          highlight Pmenu guibg=#151515 ctermbg=238
          highlight EndOfBuffer guibg=#${darkcol} ctermbg=235
          highlight LineNr guibg=NONE ctermbg=NONE
          lua require'colorizer'.setup()
          
          set nu rnu
          set termguicolors
          set runtimepath+=/usr/share/vim/vimfiles
          set mouse=a
        '';
      };

      # MPV and plugins
      programs.mpv = {
        enable = true;
	scripts = [ pkgs.mpvScripts.mpris ];
	config = {
	  volume = 70;
	  loop-playlist = "inf";
	  ytdl-format = "bestvideo+bestaudio";
	};
      };

      # Install OBS with plugins
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
	  looking-glass-obs
        ];
      };

      # Mako as a service
      services.mako = {
        enable = true;
	borderColor = "#${accentcol}";
	backgroundColor = "#${darkcol}CC";
	output = "${monitor1}";
	sort = "+time";
	layer = "overlay";
	padding = "8";
	margin = "0";
	height = 110;
	borderSize = 3;
	maxIconSize = 40;
	defaultTimeout = 6000;
	font = "Ubuntu 12";
	anchor = "bottom-right";
	extraConfig = "on-button-right=dismiss-all\nouter-margin=10\n[mode=do-not-disturb]\ninvisible=1";
      };

      # Start defining arbitrary files
      home.file = {
        # Base home directory
        ".icons/default".source = "${pkgs.simp1e-cursors}/share/icons/Simp1e-Dark";

	# Sway config folder
	".config/sway/config".text = swayconfig;
	".config/sway/programs" = { text = swayprograms; executable = true; };
	".config/sway/hardware".text = swayhardware;
	".config/sway/workspaces".text = swayworkspaces;
	".config/sway/theme".text = swaytheme;
	".config/sway/hotkeys".text = swayhotkeys;
	".config/sway/rules".text = swayrules;
	".config/sway/start.sh" = { text = swaystart; executable = true; };

	# Sway scripts
	".config/sway/scripts/bescripts.sh" = { text = bescripts; executable = true; };
	".config/sway/scripts/lock.sh" = { text = lockscript; executable = true; };
	".config/sway/scripts/notif-toggle.sh" = { text = notif-toggle; executable = true; };
	".config/sway/scripts/pin-window.sh" = { text = pin-window; executable = true; };
	".config/sway/scripts/screenshots.sh" = { text = screenshots; executable = true; };
	".config/sway/scripts/wtools.sh" = { text = wtools; executable = true; };
	".config/sway/scripts/tools/disk-cleanup.sh" = { text = disk-cleanup; executable = true; };
	".config/sway/scripts/tools/kill-proton.sh" = { text = kill-proton; executable = true; };
	".config/sway/scripts/tools/ytopus.sh" = { text = ytopus; executable = true; };
	".config/sway/scripts/alarms.sh" = { text = alarms; executable = true; };

	# Desktop wallpaper, split in 3 for 3 monitors
	"wallpaper1" = {
	  target = "Pictures/Wallpapers/Split/Downloaded/1.png";
	  source = (builtins.fetchurl {
	    url = "${colorVals.wallpaper1}";
	  });
	};
	"wallpaper2" = {
	  target = "Pictures/Wallpapers/Split/Downloaded/2.png";
	  source = (builtins.fetchurl {
	    url = "${colorVals.wallpaper2}";
	  });
	};
	"wallpaper3" = {
	  target = "Pictures/Wallpapers/Split/Downloaded/3.png";
	  source = (builtins.fetchurl {
	    url = "${colorVals.wallpaper3}";
	  });
	};
	
	# Swappy's config
	".config/swappy/config".text = swappyconfig;
	
	# Waybar config
	".config/sway/waybar/config".text = waybarconfig;
	".config/sway/waybar/style.css".text = waybarstyle;
	".config/sway/waybar/start.sh" = { text = waybarstart; executable = true; };

	# Waybar scripts
	".config/sway/waybar/scripts/clock-long.sh" = { text = clocklong; executable = true; };
	".config/sway/waybar/scripts/mpv-metadata.sh" = { text = mpvmeta; executable = true; };
	".config/sway/waybar/scripts/notif-status.sh" = { text = notifstatus; executable = true; };
	".config/sway/waybar/scripts/vram.sh" = { text = vram; executable = true; };
	".config/sway/waybar/scripts/weather.sh" = { text = weather; executable = true;	};

	# Kitty config files
	".config/kitty/kitty.conf".text = kittyconfig;
	".config/kitty/search.py".text = kittysearch;
	".config/kitty/scroll_mark.py".text = kittysearchkeys;

	# Additional imv mode for screenshots
	".config/imv/screenshot.ini".text = imvshot;

	# Easyeffects profile
	".config/easyeffects/output/JimProfile.json".text = easyprofile;

	# Mangohud config
	".config/MangoHud/MangoHud.conf".text = mangoconfig;

	# Neofetch config
	".config/neofetch/config.conf".text = neoconfig;
	".config/neofetch/small.conf".text = smallconfig;

	# PCManFM config
	".config/pcmanfm-qt/default/settings.conf".text = pcmanconf;

	# Ranger config
	".config/ranger/rc.conf".text = rangerconf;
	".config/ranger/rifle.conf".text = rifleconf;
	".config/ranger/scope.sh" = { text = scopesh; executable = true; };
	".config/ranger/plugins/devicons/__init__.py".text = iconinit;
	".config/ranger/plugins/devicons/devicons.py".text = rangericons;

	# Rofi config
	".config/rofi/config.rasi".text = roficonf;
	".config/rofi/purple.rasi".text = rofitheme;

	# Sunshine config
	".config/sunshine/apps.json".text = sunshineapps;

	# YTFZF config
	".config/ytfzf/conf.sh".text = ytfzfconf;

	# Alsoft config
	".alsoftrc".text = alsoftrc;

	# LibreWolf theming
	".librewolf/installs.ini".text = foxinstalls;
	".librewolf/profiles.ini".text = foxprofiles;
	".librewolf/Jimbo/chrome/userChrome.css".text = "${personalcolors}\n${simplefox}";
	".librewolf/Jimbo/chrome/userContent.css".text = simplefoxcontent;
	".librewolf/Jimbo/user.js".text = foxuserjs;
	".librewolf/School/chrome/userChrome.css".text = "${workcolors}\n${simplefox}";
	".librewolf/School/chrome/userContent.css".text = simplefoxcontent;
	".librewolf/School/user.js".text = foxuserjs;
	"firefox-gnome-theme" = {
	  target = ".librewolf/Variety/chrome";
	  source = (fetchTarball "https://github.com/rafaelmardojai/firefox-gnome-theme/archive/master.tar.gz");
	};
	".librewolf/Variety/user.js".text = foxuserjs;

	# Symlinks
	"VMs".source = config.lib.file.mkOutOfStoreSymlink "/etc/libvirt/VMs";
	"Mounts".source = config.lib.file.mkOutOfStoreSymlink "/mnt";
      };

      # Define session variables
      home.sessionVariables = {
	DISTRO = "nixos";
	SMB = "~/JimboSMB";
	LIBVIRT_DEFAULT_URI = "qemu:///system";
      };

      # Shell aliases
      programs.zsh = {
        enable = true;
	initExtra = "neofetch --config $(readlink -f ~/.config/neofetch/small.conf) --ascii_distro nixos_small";
        shellAliases = {
          # Shortcut aliases
          neo = "clear && neofetch";
          ip = "ip -c";
          ls = "${pkgs.eza}/bin/eza -a --color=always --group-directories-first";
          iommu = "${swayscripts}/tools/iommu-groups.sh";
          killproton = "${swayscripts}/tools/kill-proton.sh";
          sunshinehost = "WAYLAND_DISPLAY=wayland-1 DISPLAY=:1 sunshine";
          controlserver = "ssh server -t 'tmux attach -t control'";
          birth = "date -d @$(stat -c %W /) '+%a %b %d %r %Z %Y'";
	  nixcfg = "nvim /etc/nixos/{configuration.nix,jimbo.nix,hardware-configuration.nix}";
	  alarms = "cat ${swayscripts}/alarms.sh";

          # SSH Commands
          kssh="kitten ssh";
          pc="kssh 192.168.1.18";
          server="kssh 192.168.1.17";
          virtual="kssh 192.168.2.2";
          senecassh="kssh jhampton1@matrix.senecacollege.ca";
          dataws="kssh -i ~/.ssh/dat330-first.pem";
          opsrouter="kssh 44.216.132.129";
          opswww="opsrouter -p 2211";
          opsslave1="opsrouter -p 2221";
          opsslave2="opsrouter -p 2222";
          opsslave3="opsrouter -p 2223";

          # Session commands
          swaystart = "sudo systemctl start greetd";
          swayrestart = "sudo systemctl restart greetd";
          swaystop = "sudo systemctl stop greetd";

          # Curl tools
          myip = "curl ifconfig.co";
          weather = "curl wttr.in/Vaughan";

          # Download from YouTube
          ytmp4 = "yt-dlp --recode-video mp4";
          ytopus="${swayscripts}/tools/ytopus.sh";

          # Personal fixes
          cleanup = "${swayscripts}/tools/cleanup.sh";
          umountsmb = "sudo umount -Rl $SMB";
          namedisk = "sudo e2label";
          fixdisks = "${swayscripts}/tools/disk-cleanup.sh";
        };
      };

      # Define current version
      home.stateVersion = "23.11";
    };
  };
}
