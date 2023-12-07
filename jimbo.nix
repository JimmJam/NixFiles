{ config, pkgs, options, ... }:
let
  ## Global color palette
  #primeCol = ''8800FF''; #8800FF
  #accentCol = ''3b2460''; #3b2460
  #splitCol = ''69507f''; #69507f
  #actSplitCol = ''cd97fc''; #cd97fc
  #darkCol = ''202020''; #202020
  #midCol = ''282828''; #282828
  #lightCol = ''3F3F3F''; #3F3F3F
  #urgentCol = ''9E3C3C''; #9E3C3C
  #textCol = ''C7D3E3''; #C7D3E3

  ## Papirus icon theme color
  #folderCol = ''violet'';

  ## Gtk theme
  #themeSettings = {
  #  name = "Colloid-Purple-Dark-Dracula";
  #  package = pkgs.colloid-gtk-theme.override {
  #    themeVariants = [ "purple" ];
  #    colorVariants = [ "dark" ];
  #    sizeVariants = [ "standard" ];
  #    tweaks = [ "dracula" "rimless" "normal" ];
  #  };
  #};

  ## Wallpapers
  #wallpaper1 = builtins.fetchurl { 
  #  url = "https://i.imgur.com/xu3a237.png";
  #  sha256 = "1dkadvzrqbzgcwjbiflww1zwf0v6gwfb9x71ldv7g75z9nhlng7f";
  #};
  #wallpaper2 = builtins.fetchurl { 
  #  url = "https://i.imgur.com/coAKg4r.png";
  #  sha256 = "08n9kfwwg89mbhhhizk6nqm40wn4djyyfzjmalmyayyip293y02x";
  #};
  #wallpaper3 = builtins.fetchurl { 
  #  url = "https://i.imgur.com/xu3a237.png";
  #  sha256 = "1dkadvzrqbzgcwjbiflww1zwf0v6gwfb9x71ldv7g75z9nhlng7f";
  #};
  #lockpaper = builtins.fetchurl { 
  #  url = "https://i.imgur.com/6Js6nNA.png";
  #  sha256 = "1mqvp4bic46gc994fawkraqj76hxd11wdd43qakligchzd20xjd5";
  #};

  # Global color palette
  primeCol = ''3823C4''; #3823C4
  accentCol = ''1B1F59''; #1B1F59
  splitCol = ''555B9E''; #555B9E
  actSplitCol = ''5980B7''; #5980B7
  darkCol = ''101419''; #101419
  midCol = ''171C23''; #171C23
  lightCol = ''272b33''; #272b33
  urgentCol = ''9E3C3C''; #9E3C3C
  textCol = ''C7D3E3''; #C7D3E3
  
  # Papirus icon theme color
  folderCol = ''indigo'';

  # Gtk theme
  themeSettings = {
    name = "Colloid-Dark";
    package = pkgs.colloid-gtk-theme.override {
      themeVariants = [ "default" ];
      colorVariants = [ "dark" ];
      sizeVariants = [ "standard" ];
      tweaks = [ "black" "rimless" "normal" ];
    };
  };

  # Wallpapers
  wallpaper1 = pkgs.fetchurl { 
    url = "https://i.imgur.com/Wy3eIjS.png";
    sha256 = "1zxb0p0fjsmccy4xv8yk3c4kc313k3lc3xhqmiv452f7sjqqbp25";
  };
  wallpaper2 = pkgs.fetchurl { 
    url = "https://i.imgur.com/6MdUKCW.png";
    sha256 = "13jcllrs05d26iz2isvh1f8fqf20m23sps32kw7qz5iav8nhvsx7";
  };
  wallpaper3 = pkgs.fetchurl { 
    url = "https://i.imgur.com/6dCHfXP.png";
    sha256 = "16r65qnr7f0md4bbjnzq6av4dgmqr3avkilw72qdmyrmh3xj03yw";
  };
  lockpaper = pkgs.fetchurl { 
    url = "https://i.imgur.com/6Js6nNA.png";
    sha256 = "1mqvp4bic46gc994fawkraqj76hxd11wdd43qakligchzd20xjd5";
  };

  # Define paths used by different programs
  swayScripts = ''~/.config/sway/scripts'';

  # Define the workspace names
  w0 = ''0:0''; w1 = ''1:1''; w2 = ''2:2''; w3 = ''3:3''; w4 = ''4:4''; 
  w5 = ''5:5''; w6 = ''6:6''; w7 = ''7:7''; w8 = ''8:8''; w9 = ''9:9'';
  w1a = ''11:I''; w2a = ''22:II''; w3a = ''33:III''; w4a = ''44:IV''; 
  w5a = ''55:V''; w6a = ''66:VI''; w7a = ''77:VII''; w8a = ''88:VIII''; w9a = ''99:IX'';

  # Define the primary monitor
  display1 = ''DP-2'';
  display2 = ''HDMI-A-1'';
  display3 = ''DP-1'';
  displayLap = ''eDP-1'';

  # Define miscellaneous window manager properties
  borderWeightInt = 3;
  borderWeight = toString borderWeightInt;

  # Set the font across all applications I can
  mainFont = ''Ubuntu'';
  nerdFont = ''UbuntuMono Nerd Font'';

  # Set the default terminal emulator
  terminal = ''${pkgs.kitty}/bin/kitty'';
  terminalClass = ''${terminal} --class'';
  ssh = ''kitten ssh'';
  #terminal = ''${pkgs.foot}/bin/foot'';
  #terminalClass = ''${terminal} -a'';
  #ssh = ''ssh'';

  # Terminal authenticator (just in case I go back to sudo)
  auth = ''doas'';

  # Restart services to make xdg desktop portals work on Sway
  swayPipewireConf = pkgs.writeScriptBin "sway-pipewire" ''
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
    systemctl --user stop pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
    systemctl --user start pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
  '';

  # Sway still needs a start script because the sessionconfig doesn't do anything
  swayStart = ''
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

    # Prepare for the tearing patch
    export WLR_DRM_NO_ATOMIC=1
    
    # Sway/Wayland
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_DESKTOP=sway
    export QT_QPA_PLATFORM=wayland
    
    # OpenGL Variables
    export __GL_GSYNC_ALLOWED=0
    export __GL_VRR_ALLOWED=0

    # Start Sway
    sway --unsupported-gpu
  '';

  # Swappy config, for screenshot editing
  swappyConfig = ''
    [Default]
    early_exit=true
    save_dir=$HOME/Pictures/Screenshots
  '';

  # All my bemenu scripts in one file
  beScripts = let
    beMenu = ''bemenu --fn "${mainFont} 13" --nb "#${darkCol}" --ab "#${darkCol}" --tb "#${primeCol}" --fb "#${darkCol}" --tf "#FFFFFF" --hf "#FFFFFF" --hb "#${primeCol}" -f --ignorecase --hp 8 -p'';
  in pkgs.writeScriptBin "bescripts" ''
    # Scratchpad function
    handle_scratchpads() {
      SCRATCHPADS=$(echo -e "Gotop\nMusic\nPavuControl\nEasyEffects" | ${beMenu} "Scratchpads")
      case $SCRATCHPADS in
        Gotop) ${terminalClass}=gotop gotop ;;
        Music) ${terminalClass}=music ranger ;;
        PavuControl) pavucontrol ;;
        EasyEffects) easyeffects ;;
      esac
    }
    
    # Lock menu
    handle_power() {
      POWER=$(echo -e "Shutdown\nReboot\nSleep\nLock\nKill" | ${beMenu} "Power")
      case $POWER in
        Shutdown) poweroff ;;
        Reboot) reboot ;;
        Sleep) swaylock --sleep & ;;
        Lock) swaylock & ;;
        Kill) pkill -9 sway ;;
      esac
    }
    
    # Media launcher
    handle_media() {
      RET=$(echo -e "YouTube\nMusic\nHistory\nAnime" | ${beMenu} "Media")
      case $RET in
        YouTube) ytfzf -D ;;
        Music) ytfzf -D -m ;;
        History) ytfzf -D -H ;;
        Anime) ${terminal} ani-cli -q 720 ;;
      esac
    }
    
    # Resolutions
    handle_resolutions() {
      RET=$(echo -e "Default\nWide\nGPU2" | ${beMenu} "Resolutions")
      case $RET in
        Default) swaymsg reload ;;
        Wide) swaymsg "output ${display1} enable pos 1680 0 mode 1680x1050@59.954Hz
          output ${display2} enable pos 3360 0 transform 0
          output ${display3} enable pos 0 0 mode 1680x1050@59.954Hz" ;;
        GPU2) swaymsg "output ${display1} enable pos 1680 0 mode 1920x1080@60Hz
          output ${display2} enable pos 0 0 transform 0" ;;
      esac
    }
    
    # Check for command-line arguments
    if [ "$1" == "--scratchpads" ]; then
      handle_scratchpads
    elif [ "$1" == "--power" ]; then
      handle_power
    elif [ "$1" == "--games" ]; then
      handle_games
    elif [ "$1" == "--media" ]; then
      handle_media
    elif [ "$1" == "--productivity" ]; then
      handle_productivity
    elif [ "$1" == "--resolutions" ]; then
      handle_resolutions
    else
      echo "Please use a valid argument."
    fi
  '';

  # Swaylock's colors and background image
  swayLock = pkgs.writeScriptBin "swaylock" ''
    # Set the lock script
    lockscript() {
      BLANK='#00000000'
      CLEAR='#FFFFFF22'
      DEFAULT='#${primeCol}FF'
      TEXT='#FFFFFFFF'
      WRONG='#${splitCol}FF'
      VERIFYING='#${accentCol}FF'
      
      ${pkgs.swaylock-effects}/bin/swaylock -f -e \
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
      --image=${lockpaper} \
      --clock \
      --font=${mainFont} \
      --font-size=30 \
      --timestr="%I:%M%p" \
      --datestr="%a %b %d %Y"
    }
    
    # Handle whether to lock or sleep
    if [ "$1" == "--sleep" ]; then
      lockscript &
      exec ${pkgs.swayidle}/bin/swayidle -w \
      timeout 1 'swaymsg "output * dpms off"' \
      resume 'swaymsg "output * dpms on"; pkill -9 swayidle'
    else
      lockscript
    fi
  '';

  # Toggle notifications using mako
  makoToggle = pkgs.writeScriptBin "makotoggle" ''
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

  # Use grim and slurp to take screenshots in multiple ways
  screenShot = let 
    imvShot = pkgs.writeText "imv.conf" ''
      [options]
      title_text = GlobalShot
    '';
  in pkgs.writeScriptBin "screenshot" ''
    # Swappy
    handle_swappy() {
      # Create an imv window to act as a static screen
      grim -t ppm - | imv_config=${imvShot} imv - &
      imv_pid=$!
       
      # Capture the screenshot of the selected area and save to a temporary file
      selected_area=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'\
      | XCURSOR_SIZE=40 slurp -w ${borderWeight} -c ${primeCol} -B 00000066 -b 00000099)
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
      grim -t ppm - | imv_config=${imvShot} imv - &
      imv_pid=$!
       
      # Capture the screenshot of the selected area and save to a temporary file
      selected_area=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'\
      | XCURSOR_SIZE=40 slurp -w ${borderWeight} -c ${primeCol} -B 00000066 -b 00000099)
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
      echo "Please use the arguments swappy, copy, current, or all."
    fi
  '';

  # Fix disks when they are corrupted by my VM setup
  diskClean = pkgs.writeScriptBin "diskclean" ''
    # Define mount points and devices
    MOUNT1="/mnt/Linux1"
    MOUNT2="/mnt/Linux2"
    
    # Get device names
    DEVICE_1=$(df -P "$MOUNT1" | awk 'NR==2 {print $1}')
    DEVICE_2=$(df -P "$MOUNT2" | awk 'NR==2 {print $1}')
    
    # Defrag both devices
    ${auth} e4defrag -c $MOUNT1
    ${auth} e4defrag -c $MOUNT2
    
    # Unmount both mount points
    ${auth} umount "$MOUNT1"
    ${auth} umount "$MOUNT2"
    
    # Run fsck on the devices
    ${auth} fsck -f "$DEVICE_1"
    ${auth} e2fsck -f $DEVICE_1
    ${auth} fsck -f "$DEVICE_2"
    ${auth} e2fsck -f $DEVICE_2
    
    # Remount the devices
    ${auth} mount "$MOUNT1"
    ${auth} mount "$MOUNT2"
    
    echo "Disks cleaned."
  '';

  makeLinuxDrive = pkgs.writeScriptBin "makelinuxdrive" ''
    # List available drives and their sizesusing lsblk
    lsblk -dno NAME,SIZE | awk '{print $1 " (" $2 ")"}'
    
    # Prompt user to select a drive
    read -p "Please enter the name of the drive you want to select (e.g., sda, sdb, etc.): " drive_name
    
    # Check if the entered drive name exists in the lsblk output
    if lsblk -o NAME -n | grep -q "^$drive_name$"; then
    
      # Format the entire disk as GPT
      ${auth} parted /dev/$drive_name mklabel gpt
    
      # Write a 2GB FAT32 boot partition
      ${auth} parted -a optimal /dev/$drive_name mkpart primary fat32 1MiB 2GiB
    
      # Write a 4GB partition for swap
      ${auth} parted -a optimal /dev/$drive_name mkpart primary linux-swap 1GiB 5GiB
    
      # Write the rest of the drive as btrfs
      ${auth} parted -a optimal /dev/$drive_name mkpart primary btrfs 5GiB 100%
    
      # Get a partition name variable to work with not sata drives
      part_name=$(ls -l /dev/$(echo $drive_name)* | awk '{print $10}' | tail -1 | sed 's|/dev/||' | rev | cut -c 2- | rev)
    
      # Format the new partitions
      ${auth} mkfs.btrfs /dev/$(echo $part_name)3
      ${auth} mkswap /dev/$(echo $part_name)2
      ${auth} mkfs.fat -F 32 /dev/$(echo $part_name)1
    
      # Mount the btrfs partition to /mnt
      ${auth} mkdir -p /mnt/
      ${auth} mount /dev/$(echo $part_name)3 /mnt
      ${auth} mkdir -p /mnt/boot
      ${auth} mount /dev/$(echo $part_name)1 /mnt/boot
    
      # Create fstab file (has to be brought in later)
      ${auth} swapon /dev/$(echo $part_name)2
    
      echo "Drive partitioning/mounting is complete."
      break
    else
      echo "Invalid drive name. Please try again."
    fi
  '';

  # Download YouTube videos in Opus format (rather than mp3)
  ytOpus = pkgs.writeScriptBin "ytopus" ''
    # Check if an argument (URL) was provided
    if [ $# -eq 0 ]; then
      echo "No URL provided. Please provide a URL as an argument."
      exit 1
    fi
    
    # Use yt-dlp to download the URL
    yt-dlp "$1" --recode-video webm
    
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

  # Download YouTube videos in Opus format
  discordWayland = pkgs.writeScriptBin "discord" ''
    ${pkgs.vesktop}/bin/vencorddesktop --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  # Handle all my alarms
  alarmScript = let
    alarmSound = pkgs.fetchurl {
      name = "alarmSound.mp3";
      url = "https://archive.org/download/espionage_202105/Espionage.mp3";
      sha256 = "xWzbF73+VMCKWvwbN4r7Z+Rc2QuYxg01yipnaRRMq3g=";
    };
  in pkgs.writeScriptBin "alarms" ''
    #!/usr/bin/env bash
    
    # The alarm script itself
    alarm() {
      mpv --volume=40 --force-media-title="Alarm.mp3" ${alarmSound} &
      swaynag \
      --message "$name" \
      --button "Stop Alarm" alarms \
      --font ${mainFont} 12 --background ${darkCol} \
      --border ${primeCol} \
      --button-border-size ${borderWeight} \
      --button-background ${darkCol} \
      --border-bottom ${primeCol} \
      --text ${textCol} \
      --button-text ${textCol}
    }
    
    # Handle alarm times
    handle_alarms() {
    
      # Make the script loop when ran by Sway
      while true; do
        # Check the current day and time
        current_day=$(date +"%A")
        current_time=$(date +'%l:%M%p' | sed 's/^ //')
        
        # Monday alarms
        if [ "$current_day" == "Monday" ]; then
          if [ "$current_time" == "11:39AM" ]; then
            name="OPS-345 Online"; alarm
          fi
          if [ "$current_time" == "1:25PM" ]; then
            name="MST-200 Online"; alarm
          fi
          if [ "$current_time" == "3:15PM" ]; then
            name="DAT-330 Online"; alarm
          fi
        fi
        
        # Tuesday alarms
        if [ "$current_day" == "Tuesday" ]; then
          if [ "$current_time" == "10:40AM" ]; then
            name="CUL-502 Check for In Person"; alarm
          fi
        fi
    
        # Wednesday alarms
        if [ "$current_day" == "Wednesday" ]; then
          :
        fi
        
        # Thursday alarms
        if [ "$current_day" == "Thursday" ]; then
          if [ "$current_time" == "11:20AM" ]; then
            name="MST-200 In Person"; alarm
          fi
        fi
        
        # Friday alarms
        if [ "$current_day" == "Friday" ]; then
          if [ "$current_time" == "08:00AM" ]; then
            name="OPS-345 In Person"; alarm
          fi
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

  # File manager config
  pcmanConf = ''
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
    HiddenPlaces=menu://applications/, network:///, computer:///, /home/jimbo/Desktop
    
    [System]
    Archiver=file-roller
    Terminal=${terminal}
    
    [Thumbnail]
    MaxExternalThumbnailFileSize=-1
    MaxThumbnailFileSize=4096
    ShowThumbnails=true
    ThumbnailLocalFilesOnly=true
    
    [Window]
    AlwaysShowTabs=false
    PathBarButtons=true
    ShowMenuBar=true
    ShowTabClose=true
    SwitchToNewTab=true
    TabPaths=@Invalid()
  '';

  # Kitty config
  kittyConfig = ''
    # kitty.conf

    # Scrolling
    scrollback_lines 50000
    
    # Font
    font_family ${nerdFont}
    bold_font ${nerdFont}
    italic_font ${nerdFont}
    bold_italic_font ${nerdFont}
    font_size 14.5
    
    # Colors
    background #${darkCol}
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

  # Dashboard for my Debian server
  serverDash = pkgs.writeScriptBin "serverdash" ''
    ${terminalClass}=serverdash ${ssh} jimbo@server -t \
    "tmux new-session -d -s control; tmux attach -t control"
  '';

  # An Easyeffects equalizer profile that sounds good to me
  easyEffectsProfile = ''
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
  mangoConf = ''
    table_columns=2
    frametime=0
    legacy_layout=0
    font_scale=0.80
    background_alpha=0.25
    #frame_timing=0
    #position=top-right
    
    # Set the loads and such
    exec=echo $(echo $XDG_CURRENT_DESKTOP | sed 's/./\U&/') on $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2)
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
  neoConf = ''
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
  smallConf = ''
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

  pFetch = ''neofetch --config $(readlink -f ~/.config/neofetch/small.conf) --ascii_distro nixos_small'';

  # Rofi (terminal file browser) config
  rangerConf = ''
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
    default_linemode devicons
  '';

  # Choose which programs ranger uses
  rifleConf = ''
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
    mime ^ranger/x-terminal-emulator, has ${terminal} = ${terminal} -- "$@"
    
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
  rangerScope = ''
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

  # Rofi launcher main config
  rofiConf = let
    # Rofi's theme
    rofiTheme = pkgs.writeText "purple.rasi" ''
      * {
        selected-normal-foreground:  #FFFFFF;
        foreground:                  #${textCol};
        normal-foreground:           #${textCol};
        alternate-normal-foreground: #${textCol};
        normal-background:           #${darkCol}1A;
        alternate-normal-background: #${darkCol}1A;
        blue:                        #268BD2;
        red:                         #DC322F;
        selected-urgent-foreground:  #${urgentCol};
        urgent-foreground:           #${urgentCol};
        alternate-urgent-foreground: @urgent-foreground;
        alternate-urgent-background: #${accentCol}80;
        alternate-active-background: #${accentCol}80;
        active-foreground:           #${splitCol};
        lightbg:                     #EEE8D5;
        selected-active-foreground:  #${primeCol};
        background:                  #${darkCol}B3;
        bordercolor:                 #${primeCol};
        lightfg:                     #586875;
        selected-normal-background:  #${primeCol}80;
        border-color:                #${primeCol};
        spacing:                     2;
        urgent-background:           #${accentCol}26;
        selected-urgent-background:  #${splitCol}54;
        background-color:            #00000000;
        separatorcolor:              #00000000;
        alternate-active-foreground: @active-foreground;
        active-background:           #${accentCol}26;
        selected-active-background:  #${splitCol}54;
      }
      window {
        background-color: @background;
        width: 500px;
        transparency:     "real";
        border:           ${borderWeight};
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
  in ''@theme "${rofiTheme}"'';

  # Sunshine apps config
  sunshineApps = ''
    {
      "env": {
        "PATH": "$(PATH):$(HOME)\/.local\/bin"
      },
      "apps": [{
        "name": "Desktop",
        "image-path": "desktop.png"
      }]
    }
  '';

  # ytfzf config
  ytfzfConf = ''
    external_menu () {
      bemenu --fn "${mainFont} 13" --nb "#${darkCol}" --ab "#${darkCol}" --tb "#${primeCol}" --fb "#${darkCol}" --tf "#ffffff" --hf "#ffffff" --hb "#${primeCol}" -l 30 -s -p "Search:"
    }
    
    video_player () {
      mpv --loop-playlist=no --keep-open=yes "$@"
    }
  '';

  # Some sound settings use alsoft, which needs to be configured to use pipewire
  alsoftConf = ''
    drivers=pulse
  '';

  # FireFox/LibreWolf colors
  foxJimCol = ''
    :root {
      --tab-active-bg-color: #${primeCol};
      --tab-hover-bg-color: #${accentCol};
      --tab-inactive-bg-color: #${darkCol};
      --tab-active-fg-fallback-color: #FFFFFF;
      --tab-inactive-fg-fallback-color: #${textCol};
      --urlbar-focused-bg-color: #${darkCol};
      --urlbar-not-focused-bg-color: #${darkCol};
      --toolbar-bgcolor: #${darkCol} !important;
  '';
  foxWorkCol = ''
    :root {
      --tab-active-bg-color: #${darkCol};
      --tab-hover-bg-color: #${accentCol};
      --tab-inactive-bg-color: #${primeCol};
      --tab-active-fg-fallback-color: #${textCol};
      --tab-inactive-fg-fallback-color: #FFFFFF;
      --urlbar-focused-bg-color: #${primeCol};
      --urlbar-not-focused-bg-color: #${primeCol};
      --toolbar-bgcolor: #${primeCol} !important;
  '';
  quteFoxCSS = ''
      --tab-font: '${mainFont}';
      --urlbar-font: '${mainFont}';
      
      /* try increasing if you encounter problems */
      --urlbar-height-setting: 24px;
      --tab-min-height: 20px !important;
      
      /* I don't recommend you touch */
      --arrowpanel-menuitem-padding: 2px !important;
      --arrowpanel-border-radius: 0px !important;
      --arrowpanel-menuitem-border-radius: 0px !important;
      --toolbarbutton-border-radius: 0px !important;
      --toolbarbutton-inner-padding: 0px 2px !important;
      --toolbar-field-focus-background-color: var(--urlbar-focused-bg-color) !important;
      --toolbar-field-background-color: var(--urlbar-not-focused-bg-color) !important;
      --toolbar-field-focus-border-color: transparent !important;
    }
    
    /* --- GENERAL DEBLOAT ---------------------------------- */
    
    /* Bottom left page loading status or url preview */
    #statuspanel { display: none !important; }
    
    /* remove radius from right-click popup */
    menupopup, panel { --panel-border-radius: 0px !important; }
    menu, menuitem, menucaption { border-radius: 0px !important; }
    
    /* no stupid large buttons in right-click menu */
    menupopup > #context-navigation { display: none !important; }
    menupopup > #context-sep-navigation { display: none !important; }
    
    /* --- DEBLOAT NAVBAR ----------------------------------- */
    
    #back-button { display: none; }
    #forward-button { display: none; }
    #reload-button { display: none; }
    #stop-button { display: none; }
    #home-button { display: none; }
    #library-button { display: none; }
    #fxa-toolbar-menu-button { display: none; }
    /* empty space before and after the url bar */
    #customizableui-special-spring1, #customizableui-special-spring2 { display: none; }
    
    /* --- STYLE NAVBAR ------------------------------------ */
    
    /* remove padding between toolbar buttons */
    toolbar .toolbarbutton-1 { padding: 0 0 !important; }
    
    #urlbar-container {
      --urlbar-container-height: var(--urlbar-height-setting) !important;
      margin-left: 0 !important;
      margin-right: 0 !important;
      padding-top: 0 !important;
      padding-bottom: 0 !important;
      font-family: var(--urlbar-font, 'monospace');
      font-size: 14px;
    }
    
    #urlbar {
      --urlbar-height: var(--urlbar-height-setting) !important;
      --urlbar-toolbar-height: var(--urlbar-height-setting) !important;
      min-height: var(--urlbar-height-setting) !important;
      border-color: var(--lwt-toolbar-field-border-color, hsla(240,5%,5%,.25)) !important;
    }
    
    #urlbar-input {
      margin-left: 0.8em !important;
      margin-right: 0.4em !important;
    }
    
    #navigator-toolbox {
      border: none !important;
    }
    
    /* keep pop-up menus from overlapping with navbar */
    #widget-overflow { margin: 0 !important; }
    #appMenu-popup { margin: 0 !important; }
    #customizationui-widget-panel { margin: 0 !important; }
    #unified-extensions-panel { margin: 0 !important; }
    
    /* --- UNIFIED EXTENSIONS BUTTON ------------------------ */
    
    /* make extension icons smaller */
    #unified-extensions-view {
      --uei-icon-size: 18px;
    }
    
    /* hide bloat */
    .unified-extensions-item-message-deck,
    #unified-extensions-view > .panel-header,
    #unified-extensions-view > toolbarseparator,
    #unified-extensions-manage-extensions {
      display: none !important;
    }
    
    /* add 3px padding on the top and the bottom of the box */
    .panel-subview-body {
      padding: 3px 0px !important;
    }
    
    #unified-extensions-view .unified-extensions-item-menu-button {
      margin-inline-end: 0 !important;
    }
    
    #unified-extensions-view .toolbarbutton-icon {
      padding: 0 !important;
    }
    
    .unified-extensions-item-contents {
      line-height: 1 !important;
      white-space: nowrap !important;
    }
    
    /* --- DEBLOAT URLBAR ----------------------------------- */
    
    #identity-box { display: none; }
    #pageActionButton { display: none; }
    #pocket-button { display: none; }
    #urlbar-zoom-button { display: none; }
    #tracking-protection-icon-container { display: none !important; }
    #reader-mode-button{ display: none !important; }
    #star-button { display: none; }
    #star-button-box:hover { background: inherit !important; }
    
    /* Go to arrow button at the end of the urlbar when searching */
    #urlbar-go-button { display: none; }
    
    /* remove container indicator from urlbar */
    #userContext-label, #userContext-indicator { display: none !important;}
    
    /* --- STYLE TAB TOOLBAR -------------------------------- */
    
    #titlebar {
      --proton-tab-block-margin: 0px !important;
      --tab-block-margin: 0px !important;
    }
    
    #TabsToolbar, .tabbrowser-tab {
      max-height: var(--tab-min-height) !important;
      font-size: 14px !important;
    }
    
    /* Change color of normal tabs */
    tab:not([selected="true"]) {
      background-color: var(--tab-inactive-bg-color) !important;
      color: var(--identity-icon-color, var(--tab-inactive-fg-fallback-color)) !important;
    }
    
    tab {
      font-family: var(--tab-font, monospace);
      border: none !important;
    }
    
    /* safari style tab width */
    .tabbrowser-tab[fadein] {
      max-width: 100vw !important;
      border: none
    }
    
    /* Hide close button on tabs */
    #tabbrowser-tabs .tabbrowser-tab .tab-close-button { display: none !important; }
    
    .tabbrowser-tab {
      /* remove border between tabs */
      padding-inline: 0px !important;
      /* reduce fade effect of tab text */
      --tab-label-mask-size: 1em !important;
      /* fix pinned tab behaviour on overflow */
      overflow-clip-margin: 0px !important;
    }
    
    /* Tab: selected colors */
    #tabbrowser-tabs .tabbrowser-tab[selected] .tab-content {
      background: var(--tab-active-bg-color) !important;
      color: var(--identity-icon-color, var(--tab-active-fg-fallback-color)) !important;
    }
    
    /* Tab: hovered colors */
    #tabbrowser-tabs .tabbrowser-tab:hover:not([selected]) .tab-content {
      background: var(--tab-hover-bg-color) !important;
    }
    
    /* hide window controls */
    .titlebar-buttonbox-container { display: none; }
    
    /* remove titlebar spacers */
    .titlebar-spacer { display: none !important; }
    
    /* disable tab shadow */
    #tabbrowser-tabs:not([noshadowfortests]) .tab-background:is([selected], [multiselected]) {
      box-shadow: none !important;
    }
    
    /* remove dark space between pinned tab and first non-pinned tab */
    #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs]) >
    #tabbrowser-arrowscrollbox >
    .tabbrowser-tab:nth-child(1 of :not([pinned], [hidden])) {
      margin-inline-start: 0px !important;
    }
    
    /* remove dropdown menu button which displays all tabs on overflow */
    #alltabs-button { display: none !important }
    
    /* fix displaying of pinned tabs on overflow */
    #tabbrowser-tabs:not([secondarytext-unsupported]) .tab-label-container {
      height: var(--tab-min-height) !important;
    }
    
    /* remove overflow scroll buttons */
    #scrollbutton-up, #scrollbutton-down { display: none !important; }
    
    /* remove new tab button */
    #tabs-newtab-button {
      display: none !important;
    }
    
    /* --- AUTOHIDE NAVBAR ---------------------------------- */
    
    /* hide navbar unless focused */
    #nav-bar {
      min-height: 0 !important;
      max-height: 0 !important;
      height: 0 !important;
      --moz-transform: scaleY(0) !important;
      transform: scaleY(0) !important;
    }
    
    /* show on focus */
    #nav-bar:focus-within {
      --moz-transform: scale(1) !important;
      transform: scale(1) !important;
      max-height: var(--urlbar-height-setting) !important;
      height: var(--urlbar-height-setting) !important;
      min-height: var(--urlbar-height-setting) !important;
    }
    
    #navigator-toolbox:focus-within > .browser-toolbar {
      transform: translateY(0);
      opacity: 1;
    }
    
    /* --- HIDE TAB BAR ON SINGLE TAB ----------------------- */

    #tabbrowser-tabs .tabbrowser-tab:only-of-type,
    #tabbrowser-tabs .tabbrowser-tab:only-of-type + #tabbrowser-arrowscrollbox-periphery{
      display:none !important;
    }
    #tabbrowser-tabs, #tabbrowser-arrowscrollbox {min-height:0!important;}
    #alltabs-button {display:none !important;}

    /* --- PREVENT TAB FOLDING ------------------------------ */

    .tabbrowser-tab {
      min-width: initial !important;
    }
    .tab-content {
      overflow: hidden !important;
    }
  '';
  foxInstalls = ''
    [4F96D1932A9F858E]
    Default=Jimbo
    Locked=1
  '';
  foxProfiles = ''
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
  foxUserJS = ''
    // Enable Compact Mode
    user_pref("browser.uidensity", 1);
  '';
in

{
  # Define home manager programs and configs
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jimbo = { config, pkgs, ... }: {
      # Install user programs
      home.packages = (with pkgs; [
        # Useful programs
        ffmpegthumbnailer imv rofi-wayland dua p7zip qbittorrent
	neofetch libreoffice-fresh easyeffects pavucontrol gotop pciutils

        # Production tools
        krita kdenlive audacity

	# Scripts as global programs
	serverDash diskClean ytOpus makeLinuxDrive discordWayland
	beScripts makoToggle swayLock screenShot alarmScript

        # File manager
        lxqt.pcmanfm-qt gnome.file-roller ranger poppler_utils

        # Emulators
        dolphin-emu duckstation pcsx2 rpcs3

        # School tools
        remmina freerdp libvncserver globalprotect-openconnect zoom-us

        # Audio/Video tools
        yt-dlp ytfzf ani-cli playerctl ffmpeg

        # Unlimited games
        steam heroic mangohud ironwail openarena xonotic
	minetest prismlauncher wine-staging
      ]) ++ (with pkgs.unstable; [
        # Window manager apps
        swaybg wdisplays wl-clipboard wlroots_0_16
        clipman bemenu libnotify swappy
	bc grim slurp jq libsForQt5.qtstyleplugins lm_sensors
      ]) ++ (with pkgs.superstable; [
	# Remote desktop
	sunshine #moonlight-qt
      ]);

      # Enable Sway and write some scripts
      wayland.windowManager.sway = let
	# Define certain variables Sway will use
        primeMod = "Mod4";
        altMod = "Mod1";
        menuCommand = ''bemenu-run --fn "${mainFont} 13" --nb "#${darkCol}" --ab "#${darkCol}" --tb "#${primeCol}" --fb "#${darkCol}" --tf "#ffffff" --hf "#ffffff" --hb "#${primeCol}" --hp 8 --ignorecase -p "Run:"'';

	# Define scripts specific to Sway
        pinWindow = pkgs.writeScript "pin-window" ''
          # Get the current border style of the focused window
          current_style=$(swaymsg -t get_tree | jq -r '.. | select(.focused?).border')
          
          # Toggle between "normal" (default) and "pixel ${borderWeight}" border styles
          if [ "$current_style" == "none" ]; then
            swaymsg "sticky disable, border pixel ${borderWeight}"
          else
            swaymsg "sticky enable, border none"
          fi
        '';

        # Kill a window or probe it for info
        swayTools = pkgs.writeScript "swaytools" ''
          # List the app name and whether or not it uses wayland
          swayprop() {
            selected_window=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | slurp -r -c ${primeCol} -B 00000066 -b 00000000)
            if [ -n "$selected_window" ]; then
              app_id=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | select("\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" == "'"$selected_window"'") | .app_id')
              system=$(sed 's/xdg_shell/Wayland/g; s/xwayland/Xorg/g' < <(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | select("\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" == "'"$selected_window"'") | .shell'))
              notify-send "$(echo -e "Window's app_id: $app_id\nWindow System: $system")"
            fi
          }
          
          # Kill a selected window
          swaykill() {
            selected_window=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | slurp -r -c ${primeCol} -B 00000066 -b 00000000)
            if [ -n "$selected_window" ]; then
              pid=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | select("\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)" == "'"$selected_window"'") | .pid')
              kill -9 "$pid"
            fi
          }
          
          # Handle which tool we use
          if [ "$1" == "--prop" ]; then
            swayprop
          elif [ "$1" == "--kill" ]; then
            swaykill
          fi
        '';
      in {
        enable = true;
	package = pkgs.unstable.swayfx;
        wrapperFeatures.gtk = true;
	config = {
	  modifier = "${primeMod}";
	  terminal = "${terminal}";
	  startup = [
	    # Restart services to make screensharing work
	    { command = "${swayPipewireConf}/bin/sway-pipewire"; }

	    # Lock the screen on start, to allow an autostarted session
	    { command = "swaylock"; }

	    # Scratchpads
	    { command = "${terminalClass}=gotop gotop"; }
	    { command = "${terminalClass}=music ranger"; }
	    { command = "pavucontrol"; }
	    { command = "easyeffects"; }

	    # Daemons and tray apps
	    { command = "alarms --alarms"; }
	    { command = "wl-paste -t text --watch clipman store"; }
	    { command = "wl-copy"; }
	    { command = "mako"; }
	    { command = "blueman-applet"; }
	    { command = "sunshine"; }
	    { command = "${pkgs.rot8}/bin/rot8"; }

	    # Polkit agent
	    { command = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"; }

	    # Foreground apps
	    { command = "librewolf -P Variety --name=Variety"; }
	    { command = "discord"; }
	    { command = "serverdash"; }
	  ];

	  # Define which bar is used
	  bars = [{ command = "waybar"; }];

	  # Define hardware
	  output = {
            ${display1} = {
              pos = "1920 405";
	      mode = "1920x1080@143.980Hz";
              max_render_time = "3";
              bg = "${wallpaper1} fill";
              adaptive_sync = "on";
	      scale = "1";
            };
            ${display2} = {
              pos = "0 405";
	      mode = "1920x1080@75.001Hz";
              max_render_time = "3";
	      bg = "${wallpaper2} fill";
            };
            ${display3} = {
              pos = "3840 0";
	      mode = "1680x1050@59.883Hz";
	      transform = "270";
              max_render_time = "3";
	      bg = "${wallpaper3} fill";
            };
	    ${displayLap} = {
	      bg = "${wallpaper1} fill";
	      #scale = "1.4";
	    };
	  };

	  # Mouse sensitivity, disable acceleration, allow touch while typing
	  input = {
            "9610:4103:SINOWEALTH_Game_Mouse" = {
              pointer_accel = "-0.9";
            };
            "9639:64097:Compx_2.4G_Receiver_Mouse" = {
              pointer_accel = "-0.82";
            };
            "1452:627:bcm5974" = {
	      scroll_factor = "0.3";
            };
            "*" = {
              accel_profile = "flat";
	      dwt = "disabled";
	      natural_scroll = "disabled";
            };

	    # Map touchscreen to output
	    "1386:806:Wacom_ISDv5_326_Finger" = {
	      map_to_output = "${displayLap}";
	    };
	  };

	  # Assign workspaces to outputs
	  workspaceOutputAssign = let
            workspaces1 = [ "${w0}" "${w1}" "${w2}" "${w3}" "${w1a}" "${w2a}" "${w3a}" ];
            workspaces2 = [ "${w4}" "${w5}" "${w6}" "${w4a}" "${w5a}" "${w6a}" ];
            workspaces3 = [ "${w7}" "${w8}" "${w9}" "${w7a}" "${w8a}" "${w9a}" ];
            assign = output: workspaces: map (workspace: { inherit workspace; inherit output; }) workspaces;
          in
            (assign "${display1}" workspaces1) ++ (assign "${display2}" workspaces2) ++ (assign "${display3}" workspaces3);
	
	  # Theming settings
	  fonts = {
	    names = [ "${mainFont}" ];
	    size = 10.5;
	  };
	  gaps = {
	    inner = 5;
	    smartGaps = true;
	  };
	  focus = {
            newWindow = "focus";
	  };
	  colors = {
	    focused = { border = "#${primeCol}"; background = "#${primeCol}"; text = "#FFFFFF"; indicator = "#${actSplitCol}"; childBorder = "#${primeCol}"; };
	    focusedInactive = { border = "#${accentCol}"; background = "#${accentCol}"; text = "#${textCol}"; indicator = "#${splitCol}"; childBorder = "#${accentCol}"; };
	    unfocused = { border = "#${darkCol}"; background = "#${darkCol}"; text = "#${textCol}"; indicator = "#${splitCol}"; childBorder = "#${splitCol}"; };
	    urgent = { border = "#${urgentCol}"; background = "#${urgentCol}"; text = "#${textCol}"; indicator = "#${urgentCol}"; childBorder = "#${urgentCol}"; };
	  };

	  # Hotkeys
	  keybindings = {
	    ## Launcher keys

	    # Librewolf profiles
	    "${primeMod}+F1" = ''exec librewolf -P Jimbo --name=JimBrowser | notify-send "Librewolf Main" --expire-time=1500'';
	    "${primeMod}+F2" = ''exec librewolf -P School --name=SchoolBrowser | notify-send "Librewolf School" --expire-time=1500'';
	    "${primeMod}+F3" = ''exec librewolf -P Variety --name=Variety | notify-send "Librewolf Variety" --expire-time=1500'';

	    # Looking glass for VMs
	    "${primeMod}+F4" = ''exec looking-glass-client -p 5950 input:rawMouse=yes | notify-send "Looking Glass" --expire-time=1500'';

	    # Games
	    "${primeMod}+F5" = ''exec steam | notify-send "Steam" --expire-time=1500'';
	    "${primeMod}+F6" = ''exec ${terminalClass}=HeroicTerminal heroic | notify-send "Heroic Games" --expire-time=1500'';

	    # Virtual Machines
	    "${primeMod}+F10" = ''exec virt-manager | notify-send "Virtual Machines" --expire-time=1500'';

	    # BeMenu scripts
	    "${primeMod}+F11" = ''exec bescripts --scratchpads | notify-send "Scratchpads" --expire-time=1500'';
	    "${primeMod}+${altMod}+Ctrl+r" = ''exec bescripts --resolutions'';

	    # Open NixOS configuration files
	    "${primeMod}+F12" = ''exec bash -c "${terminal} nvim /etc/nixos/{configuration.nix,jimbo.nix}" | notify-send "Nix Config" --expire-time=1500'';

	    # Kitty, bemenu, clipmenu, media script, power menu, show/hide waybar
	    "${primeMod}+Return" = ''exec ${terminal}'';
	    "${primeMod}+s" = ''exec ${menuCommand}'';
	    "${primeMod}+c" = ''exec clipman pick -t rofi -T'-font "${mainFont} 13"' '';
	    "${primeMod}+y" = ''exec bescripts --media'';
	    "${primeMod}+x" = ''exec bescripts --power'';
	    "${primeMod}+b" = ''exec pkill -USR1 waybar'';
	    "${primeMod}+Escape" = ''exec ${swayTools} --kill'';

	    # PCManFM, Emoji Picker, Ranger, Rofi Launcher
	    "${primeMod}+Shift+t" = ''exec pcmanfm-qt'';
	    "${primeMod}+Shift+e" = ''exec BEMOJI_PICKER_CMD="eval rofi -font '${mainFont} 13' -dmenu -p Emoji" ${pkgs.bemoji}/bin/bemoji -n -P 0'';
	    "${primeMod}+Shift+s" = ''exec rofi -show drun -drun-display-format {name} -show-icons -modi drun -font "${mainFont} 14"'';
	    "${primeMod}+Shift+Return" = ''exec ${terminal} ranger'';

	    # Wprop, colorpicker
	    "${primeMod}+Ctrl+x" = ''exec ${swayTools} --prop'';
	    "${primeMod}+Ctrl+c" = ''exec ${pkgs.hyprpicker}/bin/hyprpicker -an && notify-send "Color copied to clipboard" --expire-time=1500'';

	    ## Media keys

	    # Volume control
	    "XF86AudioRaiseVolume" = ''exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'';
	    "XF86AudioLowerVolume" = ''exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'';

	    # MPV volume control
	    "${altMod}+XF86AudioRaiseVolume" = ''exec playerctl --player=mpv volume 0.05+'';
	    "${altMod}+XF86AudioLowerVolume" = ''exec playerctl --player=mpv volume 0.05-'';

	    # Mute, Stop
	    "XF86AudioMute" = ''exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'';
	    "XF86AudioStop" = ''exec playerctl --player=mpv stop'';

	    # Play MPV or Firefox
	    "XF86AudioPlay" = ''exec playerctl --player=firefox play-pause'';
	    "${altMod}+XF86AudioPlay" = ''exec playerctl --player=mpv play-pause'';

	    # Next/Previous
	    "XF86AudioNext" = ''exec playerctl --player=firefox next'';
	    "XF86AudioPrev" = ''exec playerctl --player=firefox previous'';
	    "${altMod}+XF86AudioNext" = ''exec playerctl --player=mpv next'';
	    "${altMod}+XF86AudioPrev" = ''exec playerctl --player=mpv previous'';

	    ## Notification keys

	    # Toggle mako
	    "${primeMod}+n" = ''exec makotoggle'';
	    "${primeMod}+Shift+n" = ''exec makoctl restore'';
	    "${primeMod}+Ctrl+n" = ''exec makoctl dismiss -a'';

	    ## Miscellaneous keys

	    # Screenshots
	    "Print" = ''exec screenshot --swappy'';
	    "${primeMod}+Shift+f" = ''exec screenshot --swappy'';
	    "Alt+Print" = ''exec screenshot --copy'';
	    "Shift+Print" = ''exec screenshot --current'';
	    "Ctrl+Print" = ''exec screenshot --all'';

	    # Server SSH
	    "${primeMod}+Ctrl+Return" = ''exec ${terminal} ${ssh} server'';

	    # Open copied video link in mpv
	    "${primeMod}+Ctrl+y" = ''exec mpv --loop-playlist=no --keep-open=yes $(echo $(wl-paste)) | notify-send "Playing in MPV" --expire-time=1500'';

	    # Display Brightness and Keyboard Brightness
	    "XF86MonBrightnessUp" = ''exec light -A 5'';
	    "XF86MonBrightnessDown" = ''exec light -U 5'';
	    "Shift+XF86MonBrightnessUp" = ''exec light -A 1'';
	    "Shift+XF86MonBrightnessDown" = ''exec light -U 1'';
	    "XF86KbdBrightnessUp" = ''exec light -s sysfs/leds/smc::kbd_backlight -A 5'';
	    "XF86KbdBrightnessDown" = ''exec light -s sysfs/leds/smc::kbd_backlight -U 5'';

	    ## Window manager keys
	    "${primeMod}+q" = ''kill'';
	    "${primeMod}+Shift+r" = ''reload'';

	    # Switch to workspaces
	    "${primeMod}+grave" = ''workspace ${w0}'';
	    "${primeMod}+1" = ''workspace ${w1}'';
	    "${primeMod}+2" = ''workspace ${w2}'';
	    "${primeMod}+3" = ''workspace ${w3}'';
	    "${primeMod}+4" = ''workspace ${w4}'';
	    "${primeMod}+5" = ''workspace ${w5}'';
	    "${primeMod}+6" = ''workspace ${w6}'';
	    "${primeMod}+7" = ''workspace ${w7}'';
	    "${primeMod}+8" = ''workspace ${w8}'';
	    "${primeMod}+9" = ''workspace ${w9}'';

	    # Switch to alternate workspaces
	    "${altMod}+F1" = ''workspace ${w1a}'';
	    "${altMod}+F2" = ''workspace ${w2a}'';
	    "${altMod}+F3" = ''workspace ${w3a}'';
	    "${altMod}+F4" = ''workspace ${w4a}'';
	    "${altMod}+F5" = ''workspace ${w5a}'';
	    "${altMod}+F6" = ''workspace ${w6a}'';
	    "${altMod}+F7" = ''workspace ${w7a}'';
	    "${altMod}+F8" = ''workspace ${w8a}'';
	    "${altMod}+F9" = ''workspace ${w9a}'';

	    # Move window to and focus new workspace
	    "${primeMod}+Shift+grave" = ''move container to workspace ${w0}; workspace ${w0}'';
	    "${primeMod}+Shift+1" = ''move container to workspace ${w1}; workspace ${w1}'';
	    "${primeMod}+Shift+2" = ''move container to workspace ${w2}; workspace ${w2}'';
	    "${primeMod}+Shift+3" = ''move container to workspace ${w3}; workspace ${w3}'';
	    "${primeMod}+Shift+4" = ''move container to workspace ${w4}; workspace ${w4}'';
	    "${primeMod}+Shift+5" = ''move container to workspace ${w5}; workspace ${w5}'';
	    "${primeMod}+Shift+6" = ''move container to workspace ${w6}; workspace ${w6}'';
	    "${primeMod}+Shift+7" = ''move container to workspace ${w7}; workspace ${w7}'';
	    "${primeMod}+Shift+8" = ''move container to workspace ${w8}; workspace ${w8}'';
	    "${primeMod}+Shift+9" = ''move container to workspace ${w9}; workspace ${w9}'';

	    # Move window to and focus new alternate workspace
	    "${altMod}+Shift+F1" = ''move container to workspace ${w1a}; workspace ${w1a}'';
	    "${altMod}+Shift+F2" = ''move container to workspace ${w2a}; workspace ${w2a}'';
	    "${altMod}+Shift+F3" = ''move container to workspace ${w3a}; workspace ${w3a}'';
	    "${altMod}+Shift+F4" = ''move container to workspace ${w4a}; workspace ${w4a}'';
	    "${altMod}+Shift+F5" = ''move container to workspace ${w5a}; workspace ${w5a}'';
	    "${altMod}+Shift+F6" = ''move container to workspace ${w6a}; workspace ${w6a}'';
	    "${altMod}+Shift+F7" = ''move container to workspace ${w7a}; workspace ${w7a}'';
	    "${altMod}+Shift+F8" = ''move container to workspace ${w8a}; workspace ${w8a}'';
	    "${altMod}+Shift+F9" = ''move container to workspace ${w9a}; workspace ${w9a}'';

	    # Change focus across windows
	    "${primeMod}+Up" = ''focus up'';
	    "${primeMod}+Down" = ''focus down'';
	    "${primeMod}+Left" = ''focus left'';
	    "${primeMod}+Right" = ''focus right'';

	    # Switch focus across outputs
	    "${primeMod}+j" = ''focus output ${display2}'';
	    "${primeMod}+k" = ''focus output ${display1}'';
	    "${primeMod}+l" = ''focus output ${display3}'';

	    # Move focused window
	    "${primeMod}+Shift+Up" = ''move up'';
	    "${primeMod}+Shift+Down" = ''move down'';
	    "${primeMod}+Shift+Left" = ''move left'';
	    "${primeMod}+Shift+Right" = ''move right'';

	    # Move window across outputs
	    "${primeMod}+Shift+j" = ''move output ${display2}; focus output ${display2}'';
	    "${primeMod}+Shift+k" = ''move output ${display1}; focus output ${display1}'';
	    "${primeMod}+Shift+l" = ''move output ${display3}; focus output ${display3}'';

	    # Change focus between floating/tiled, toggle floating
	    "${primeMod}+space" = ''focus mode_toggle'';
	    "${primeMod}+Shift+space" = ''floating toggle'';

	    # Allow a window to be visible on all workspaces, toggle border
	    "${primeMod}+0" = ''exec ${pinWindow}'';

	    # Toggle fullscreen
	    "${primeMod}+f" = ''fullscreen toggle'';
	    "${primeMod}+${altMod}+Ctrl+f" = ''fullscreen toggle global'';

	    # Change container layout
	    "${primeMod}+w" = ''layout toggle split'';
	    "${primeMod}+e" = ''layout tabbed'';

	    # Change split direction
	    "${primeMod}+h" = ''split h'';
	    "${primeMod}+v" = ''split v'';

	    # Focus parent / child
	    "${primeMod}+a" = ''focus parent'';
	    "${primeMod}+d" = ''focus child'';

	    # Resize windows
	    "${primeMod}+${altMod}+Up" = ''resize grow height 5 px or 5 ppt'';
	    "${primeMod}+${altMod}+Down" = ''resize shrink height 5 px or 5 ppt'';
	    "${primeMod}+${altMod}+Left" = ''resize shrink width 5 px or 5 ppt'';
	    "${primeMod}+${altMod}+Right" = ''resize grow width 5 px or 5 ppt'';

	    # Adjust gap size
	    "${primeMod}+Shift+equal" = ''gaps inner current set 5'';
	    "${primeMod}+equal" = ''gaps inner current plus 5'';
	    "${primeMod}+minus" = ''gaps inner current minus 5'';

	    # Scratchpads
	    "Ctrl+Shift+Escape" = ''[app_id="gotop"] scratchpad show, move position center'';
	    "${primeMod}+Shift+m" = ''[app_id="music"] scratchpad show, move position center'';
	    "${primeMod}+Shift+v" = ''[app_id="pavucontrol"] scratchpad show, move position center'';
	    "${primeMod}+Shift+Backslash" = ''[app_id="com.github.wwmm.easyeffects"] scratchpad show, move position center'';
	  };
	  window = {
            border = borderWeightInt;
	    titlebar = false;
	    commands = [
	      # Scratchpads
	      { command = ''floating enable, sticky enable, move scratchpad, mark borderless'';
	      criteria = { con_mark = "scratchpad"; }; }
	      { command = ''mark scratchpad, resize set 1200 900'';
	      criteria = { app_id = "gotop"; }; }
	      { command = ''mark scratchpad, resize set 1000 650'';
	      criteria = { app_id = "music"; }; }
	      { command = ''mark scratchpad, resize set 1000 800, opacity 0.9'';
	      criteria = { app_id = "pavucontrol"; }; }
	      { command = ''mark scratchpad, resize set 1000 800, opacity 0.9'';
	      criteria = { app_id = "com.github.wwmm.easyeffects"; }; }

	      # Create a "Scratchpad" for apps I don't want to be seen when launched
	      { command = ''move scratchpad''; criteria = { con_mark = "hiddenaway"; }; }
	      { command = ''mark hiddenaway''; criteria = { app_id = "HeroicTerminal"; }; }

	      # Give apps that don't have them borders
	      { command = ''border pixel ${borderWeight}''; criteria = { con_mark = "borderless"; }; }
	      { command = ''mark borderless''; criteria = { app_id = "com.github.wwmm.easyeffects"; }; }
	      { command = ''mark borderless''; criteria = { class = "steam"; }; }
	      { command = ''mark borderless''; criteria = { app_id = "swappy"; }; }
	      { command = ''mark borderless''; criteria = { app_id = "virt-manager"; }; }
	      { command = ''mark borderless''; criteria = { window_role = "pop-up"; }; }

	      # Floating or fullscreen rules
	      { command = ''floating enable''; criteria = { app_id = "smb"; }; }
	      { command = ''floating enable''; criteria = { app_id = "float"; }; }
	      { command = ''floating enable, fullscreen enable global''; criteria = { title = "^GlobalShot"; }; }
	    ];
          };
	  assigns = {
	    # Browsers
	    "${w1}" = [{ app_id = "JimBrowser"; }];
	    "${w1a}" = [{ app_id = "SchoolBrowser"; }];
	    "${w7}" = [{ app_id = "Variety"; }];
	    
	    # Communication
	    "${w6a}" = [{ class = "zoom"; }];
	    "${w8}" = [{ app_id = "VencordDesktop"; }];

	    # Else
	    "${w2}" = [{ class = "steam"; } { class = "heroic"; }];
	    "${w2a}" = [{ app_id = "looking-glass-client"; }];
	    "${w4}" = [{ app_id = "serverdash"; }];
	    "${w4a}" = [{ app_id = "com.obsproject.Studio"; }];
	  };
	};
	extraConfig = ''
          # Options I can't find in Nix yet
          default_floating_border pixel ${borderWeight}
          hide_edge_borders --i3 smart
          titlebar_padding 10 1
          
          # SwayFX specific options
          blur enable
          blur_passes 3
          blur_radius 5
          
          # Set transparency rules
          layer_effects 'rofi' blur enable
          layer_effects 'notifications' blur enable; blur_ignore_transparent enable
          
          # Include extra window icons
          include ${pkgs.fetchurl {
	    url = "https://raw.githubusercontent.com/iguanajuice/sway-font-awesome/6b7a9d08974eea1b9cddb8d444e1c89d6837083a/icons";
	    sha256 = "09ki5qw1h91kd33k3fwzq7cb6ck8sq4haswgizrsy387sfr2a75x";
	  }}
          
          # Switch to workspace 1
          workspace ${w7}
          workspace ${w1}
	'';
      };

      # Define Waybar
      programs.waybar = let
        # Sway workspaces
        swayWorkspacesModule = {
	  format = "{name}";
          enable-bar-scroll = true;
          warp-on-scroll = false;
          disable-scroll-wraparound = true;
        };

	# Sway windows
	swayWindowsModule = {
	  icon = true;
	  icon-size = 15;
	  all-outputs = true;
	  tooltip = false;
	  rewrite = {
	    "(.*) — LibreWolf" = "   $1";
	    "LibreWolf" = "   LibreWolf";
	    "(.*) - YouTube — LibreWolf" = "󰗃   $1";
	  };
	};

	# Pipewire/Pulseaudio
	pulseModule = {
	  format = "{icon}   {volume}%";
	  format-bluetooth = "{icon}  {volume}%";
	  format-muted = " muted";
	  format-icons = {
	    default = [ "" "" ];
	    headphone = "";
	  };
	  on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
	  on-click-middle = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%";
	  on-click-right = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 60%";
	  ignored-sinks = [ "Easy Effects Sink" "USB FS AUDIO Analog Stereo" ];
	};

	# CPU, Ram and Vram
	cpuModule = {
	  format = "  {usage}%";
	  interval = 3;
	};
	ramModule = {
	  format = "  {used}G";
	  tooltip = false;
	};
	vramModule = {
	  exec = pkgs.writeScript "vramScript" ''
            # Don't run the script if running on integrated graphics
            if lspci -k | grep "Kernel driver in use: nvidia" &> /dev/null || lspci -k | grep "Kernel driver in use: amdgpu" &> /dev/null; then
            
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
            
            else
              :
            fi
	  '';
	  format = "{}";
	  return-type = "json";
	  interval = 3;
	};

	# Clocks
	longClockModule = {
	  exec = pkgs.writeScript "longClock" ''
            # Long clock format, with a numeric date and military time tooltip
            time=$(date +'%a %b %d %l:%M:%S%p' | tr -s ' ')
            date=$(date "+%Y-%m-%d")
            echo "{\"text\":\"  $time\",\"tooltip\":\"$date\"}"
	  '';
	  on-click = "wl-copy $(date \"+%Y-%m-%d-%H%M%S\"); notify-send \"Date copied.\"";
	  format = "{}";
	  return-type = "json";
	  interval = 1;
	  tooltip = true;
	};
	shortClockModule = {
	  exec = "echo '  '$(date +'%l:%M%p' | sed 's/^ //')";
	  on-click = "wl-copy $(date \"+%Y-%m-%d-%H%M%S\"); notify-send \"Date copied.\"";
	  interval = 60;
	  tooltip = false;
	};

	# Tray, gamemode and network tray modules
	trayModule = {
	  spacing = 5;
	};
	networkModule = {
	  format-ethernet = "󰈀";
	  format-wifi = "";
	  format-disconnected = "󰖪";
	  format-linked = "";
	  tooltip-format-ethernet = "{ipaddr}\n{ifname} ";
	  tooltip-format-wifi = "{ipaddr}\n{essid} ({signalStrength}%)";
	  tooltip-format-disconnected = "Disconnected";
	};
	scratchpadModule = {
	  format = "   {count}";
	  show-empty = false;
	  tooltip = true;
	  tooltip-format = "{title}";
	};
	gamemodeModule = {
	  format = "{glyph}";
	  glyph = "󰖺";
	  hide-not-running = true;
	  use-icon = true;
	  icon-spacing = 3;
	  icon-size = 19;
	  tooltip = true;
	  tooltip-format = "Gamemode On";
	};

	# Special per-bar modules
	mediaModule = {
	  exec-if = "playerctl --player=mpv status";
	  exec = pkgs.writeScript "mpvMetadata" ''
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
	  format = "{}";
	  return-type = "json";
	  interval = 2;
	  max-length = 30;
	  on-click = "playerctl --player=mpv play-pause";
	  on-click-middle = "pkill -9 mpv";
	};
	notificationModule = {
	  exec = pkgs.writeScript "notificationScript" ''
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
	  format = "{}";
	  return-type = "json";
	  interval = 2;
	  on-click = "makotoggle";
	};
	weatherModule = {
	  exec = pkgs.writeScript "weatherScript" ''
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
	  format = "<span font_size='11pt'>{}</span>";
	  return-type = "json";
	  on-click = "librewolf --new-tab https://openweathermap.org/city/6173577";
	  interval = 150;
	};

	# Laptop modules
	backlightModule = {
	  format = "{icon}  {percent}%";
	  format-icons = ["" "󰖨"];
	  tooltip = true;
	};
	batteryModule = {
	  interval = 60;
	  states = {
	    warning = 30;
	    critical = 15;
	  };
	  format = "{icon}   {capacity}%";
	  format-icons = ["" "" "" "" ""];
	};
      in {
        enable = true;
	settings = {
	  display1 = {
	    name = "bar1";
	    position = "top";
	    layer = "bottom";
	    output = [ display1 ];
	    modules-left = [ "sway/workspaces" "sway/window" ];
	    modules-right = 
	      [ "pulseaudio" "cpu" "memory" "custom/vram" "custom/clock-long" "gamemode" "sway/scratchpad" "tray" "network" ];
	    "sway/workspaces" = swayWorkspacesModule;
	    "sway/window" = swayWindowsModule;
	    "pulseaudio" = pulseModule;
	    "cpu" = cpuModule;
	    "memory" = ramModule;
	    "custom/vram" = vramModule;
	    "custom/clock-long" = longClockModule;
	    "gamemode" = gamemodeModule;
	    "sway/scratchpad" = scratchpadModule;
	    "tray" = trayModule;
	    "network" = networkModule // { interface = "enp42s0"; };
	  };
	  display2 = {
	    name = "bar2";
	    position = "top";
	    layer = "bottom";
	    output = [ display2 ];
	    modules-left = [ "sway/workspaces" "sway/window" ];
	    modules-right =
	      [ "pulseaudio" "custom/media" "custom/notifs" "cpu" "memory" "custom/vram" "custom/clock-long" ];
	    "sway/workspaces" = swayWorkspacesModule;
	    "sway/window" = swayWindowsModule;
	    "pulseaudio" = pulseModule;
	    "custom/media" = mediaModule;
	    "custom/notifs" = notificationModule;
	    "cpu" = cpuModule;
	    "memory" = ramModule;
	    "custom/vram" = vramModule;
	    "custom/clock-long" = longClockModule;
	  };
	  display3 = {
	    name = "bar3";
	    position = "top";
	    layer = "bottom";
	    output = [ display3 ];
	    modules-left = [ "sway/workspaces" "sway/window" ];
	    modules-right =
	      [ "pulseaudio" "custom/weather" "cpu" "memory" "custom/vram" "custom/clock-short" ];
	    "sway/workspaces" = swayWorkspacesModule;
	    "sway/window" = swayWindowsModule;
	    "pulseaudio" = pulseModule;
	    "custom/weather" = weatherModule;
	    "cpu" = cpuModule;
	    "memory" = ramModule;
	    "custom/vram" = vramModule;
	    "custom/clock-short" = shortClockModule;
	  };
	  displayLap = {
	    name = "laptop";
	    position = "top";
	    layer = "bottom";
	    output = [ "eDP-1" "LVDS-1" "DSI-1" ];
	    modules-left = [ "sway/workspaces" "sway/window" ];
	    modules-right = [ "pulseaudio" "custom/media" "custom/notifs" "cpu" "memory" "custom/vram" "backlight" "battery" "custom/clock-long" "gamemode" "sway/scratchpad" "tray" "network" ];
	    "sway/workspaces" = swayWorkspacesModule;
	    "sway/window" = swayWindowsModule;
	    "pulseaudio" = pulseModule;
	    "custom/media" = mediaModule;
	    "custom/notifs" = notificationModule;
	    "cpu" = cpuModule;
	    "memory" = ramModule;
	    "custom/vram" = vramModule;
	    "backlight" = backlightModule;
	    "battery" = batteryModule;
	    "custom/clock-long" = longClockModule;
	    "sway/scratchpad" = scratchpadModule;
	    "tray" = trayModule;
	    "network" = networkModule // { interface = "wlan0"; };
	  };
	};
	style = ''
          * {
            border: 0;
            border-radius: 0;
            min-height: 0;
            font-family: ${mainFont}, ${nerdFont};
            color: #${textCol};
          }
          .bar1,.bar2,.bar3,.laptop {
            font-size: 15.5px;
          }
          #waybar {
            background: #${darkCol};
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
            border-bottom: 3px solid #${primeCol};
            background: #${midCol};
          }
          #workspaces button.urgent {
            border-bottom: 3px solid #900000;
          }
          #workspaces button:hover {
            box-shadow: none;
            background: #${lightCol};
          }
          #scratchpad {
            margin-left: 2px;
          }
          #cpu {
            border-bottom: 3px solid #f90000;
            margin-left: 2px;
            margin-right: 5px;
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
          #custom-media {
            border-bottom: 3px solid #ffb066;
            margin-left: 2px;
            margin-right: 5px;
          }
          #custom-clock-long {
            border-bottom: 3px solid #0a6cf5;
            margin-left: 2px;
            margin-right: 5px;
          }
          #custom-clock-short {
            border-bottom: 3px solid #0a6cf5;
            margin-left: 2px;
            margin-right: 3px;
          }
          #backlight {
            border-bottom: 3px solid #5ffca3;
            margin-left: 2px;
            margin-right: 5px;
          }
          #battery {
            border-bottom: 3px solid #fcfc16;
            margin-left: 2px;
            margin-right: 5px;
          }
          #custom-media.paused {
            color: #888;
          }
          #custom-weather {
            border-bottom: 3px solid #${primeCol};
            margin-left: 2px;
            margin-right: 5px;
          }
          #custom-notifs {
            border-bottom: 3px solid #${primeCol};
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
      };

      # Define GTK theme settings
      gtk = {
        enable = true;
	font = {
          name = "${mainFont}";
          size = 11;
	};
        theme = themeSettings;
        iconTheme = {
	  package = pkgs.papirus-icon-theme.override { color = "${folderCol}"; };
	  name = "Papirus-Dark";
	};
        cursorTheme = {
          package = pkgs.simp1e-cursors;
          name = "Simp1e-Dark";
        };

	# GTK app bookmarks
	gtk3.bookmarks = [
	  # Local
	  "file:///home/jimbo/Downloads"
	  "file:///home/jimbo/Documents"
	  "file:///home/jimbo/Pictures/Screenshots"

	  # Remote
          "file:///home/jimbo/JimboNFS/Downloads"
          "file:///home/jimbo/JimboNFS/Documents"
          "file:///home/jimbo/JimboNFS/Music"
          "file:///home/jimbo/JimboNFS/Photos"
          "file:///home/jimbo/JimboNFS/Videos"
          "file:///home/jimbo/JimboNFS/MineServers"

	  # Links and mounts
          "file:///home/jimbo/VMs"
          "file:///home/jimbo/Mounts"
          "file:///home/jimbo/Games"

	  # More important stuff
	  "file:///home/jimbo/JimboNFS/JimboOS"
          "file:///home/jimbo/JimboNFS/School"
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

      # Select default apps
      xdg.mimeApps.defaultApplications = {
        "inode/directory" = "pcmanfm-qt.desktop";
        "text/plain" = "nvim.desktop";
        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
      };

      # Set dconf settings
      dconf.settings = {
	"org/gnome/desktop/interface/color-scheme" = {
	  color-scheme = "prefer-dark";
	};
       "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
      };

      # Install LibreWolf with settings
      programs.librewolf = {
        enable = true;
	package = pkgs.unstable.librewolf;
	settings = {
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "network.cookie.lifetimePolicy" = 0;
	  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
	  "browser.compactmode.show" = true;
	  "browser.toolbars.bookmarks.visibility" = "newtab";
	  "gnomeTheme.hideSingleTab" = true;
	  "svg.context-properties.content.enabled" = true;
	  "media.hardware-video-decoding.force-enabled" = true;
	  "toolkit.tabbox.switchByScrolling" = true;
	  "device.sensors.motion.enabled" = false;
        };
      };

      # Install Neovim and plugins
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
	  # Vim theme
          vim-airline vim-airline-themes

	  # Internal clipboard
          vim-vsnip cmp-vsnip

	  # Autocomplete manager
          lspkind-nvim

	  # Autocomplete plugins
          cmp-nvim-lsp cmp-buffer cmp-path cmp-cmdline nvim-cmp

	  # Directory tree viewer
          nerdtree

	  # Hex color visualizer and color theme
          nvim-colorizer-lua vim-monokai-pro
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
          
          colorscheme monokai_pro
          let g:airline_theme='onedark'
          let g:airline#extensions#tabline#enabled = 1
          highlight Normal guibg=#${darkCol} ctermbg=235
          highlight Visual guibg=#151515 ctermbg=238
          highlight Pmenu guibg=#151515 ctermbg=238
          highlight EndOfBuffer guibg=#${darkCol} ctermbg=235
          highlight LineNr guibg=NONE ctermbg=NONE
          lua require'colorizer'.setup()
          
          set nu rnu
          set termguicolors
          set runtimepath+=/usr/share/vim/vimfiles
          set mouse=a

          nmap <C-a> :NERDTreeToggle<CR>
          nmap <C-x> :bnext<CR>
          nmap <C-z> :bprev<CR>
        '';
      };

      # MPV settings
      programs.mpv = {
        enable = true;
	config = {
	  volume = 70;
	  loop-playlist = "inf";
	  osc = "no";
	};
      };

      # OBS with plugins
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
	  obs-vkcapture
	  obs-pipewire-audio-capture
	  looking-glass-obs
        ];
      };

      # Notification daemon
      services.mako = {
        enable = true;
	borderColor = "#${accentCol}";
	backgroundColor = "#${darkCol}CC";
	output = "${display1}";
	sort = "+time";
	layer = "overlay";
	padding = "8";
	margin = "0";
	borderSize = borderWeightInt;
	maxIconSize = 40;
	defaultTimeout = 6000;
	font = "${mainFont} 12";
	anchor = "bottom-right";
        extraConfig = "on-button-right=dismiss-all\nouter-margin=10\n[mode=do-not-disturb]\ninvisible=1";
      };

      # Start defining arbitrary files
      home.file = {
	# Sway scripts
	".config/sway/start.sh" = { text = swayStart; executable = true; };

        # Cursor icon theme
        ".icons/default".source = "${pkgs.simp1e-cursors}/share/icons/Simp1e-Dark";
	
	# Swappy's config
	".config/swappy/config".text = swappyConfig;

	# Kitty config files
	".config/kitty/kitty.conf".text = kittyConfig;
	".config/kitty/search.py".source = "${pkgs.fetchurl {
	  url = "https://raw.githubusercontent.com/trygveaa/kitty-kitten-search/0760138fad617c5e4159403cbfce8421ccdfe571/search.py";
	  sha256 = "1w50fimqsbmqk9zhdmq8k2v1b36iwsglpbqaavpglw0acam3xid7";
	}}";
	".config/kitty/scroll_mark.py".source = "${pkgs.fetchurl {
	  url = "https://raw.githubusercontent.com/trygveaa/kitty-kitten-search/9fbfc578bc27475003cdf3de1b3d1f8ef8b66658/scroll_mark.py";
	  sha256 = "1a1l7sp2x247da8fr54wwq7ffm987wjal9nw2f38q956v3cfknzi";
	}}";

	# Easyeffects profile
	".config/easyeffects/output/JimProfile.json".text = easyEffectsProfile;

	# Mangohud config
	".config/MangoHud/MangoHud.conf".text = mangoConf;

	# Neofetch config
	".config/neofetch/config.conf".text = neoConf;
	".config/neofetch/small.conf".text = smallConf;

	# PCManFM config
	".config/pcmanfm-qt/default/settings.conf".text = pcmanConf;

	# Ranger config
	".config/ranger/rc.conf".text = rangerConf;
	".config/ranger/rifle.conf".text = rifleConf;
	".config/ranger/scope.sh" = { text = rangerScope; executable = true; };
	".config/ranger/plugins/devicons/devicons.py".source = "${pkgs.fetchurl {
	  url = "https://raw.githubusercontent.com/alexanderjeurissen/ranger_devicons/main/devicons.py";
	  sha256 = "16xg5wrbck4fvp3pjmwspzb1n5yd4giv1gajpb0v9xnmpyifb715";
	}}";
	".config/ranger/plugins/devicons/__init__.py".source = "${pkgs.fetchurl {
	  url = "https://raw.githubusercontent.com/alexanderjeurissen/ranger_devicons/main/__init__.py";
	  sha256 = "1r086apw20ryxylqgnbynx7mzz779v1w0m40wghmmhlzw4x15fmr";
	}}";

	# Rofi config
	".config/rofi/config.rasi".text = rofiConf;

	# Sunshine config
	".config/sunshine/apps.json".text = sunshineApps;

	# YTFZF config
	".config/ytfzf/conf.sh".text = ytfzfConf;

	# Alsoft config
	".alsoftrc".text = alsoftConf;

	# LibreWolf profiles and theming
	".librewolf/installs.ini".text = foxInstalls;
	".librewolf/profiles.ini".text = foxProfiles;
	".librewolf/Jimbo/chrome/userChrome.css".text = "${foxJimCol}\n${quteFoxCSS}";
	".librewolf/Jimbo/user.js".text = foxUserJS;
	".librewolf/School/chrome/userChrome.css".text = "${foxWorkCol}\n${quteFoxCSS}";
	".librewolf/School/user.js".text = foxUserJS;
	".librewolf/Variety/chrome".source = "${fetchTarball {
	  url = "https://codeload.github.com/rafaelmardojai/firefox-gnome-theme/tar.gz/ec9421f82d922b7293ffd45a47f7abdee80038c6";
	  sha256 = "130xnb04a0ikrq414kn1yg1jwk9vjfd8fk89q17c4c37qhhlyax4";
	}}";
	".librewolf/Variety/user.js".text = foxUserJS;

	# Qbittorrent
	".config/qBittorrent/qbitMatterialUI".source = "${fetchTarball {
	  url = "https://github.com/bill-ahmed/qbit-matUI/releases/download/v1.16.4/qbit-matUI_Unix_1.16.4.zip";
	  sha256 = "1calmngqgzfska3qh082ini8z71c2pdnvkq763iz1k5wmfh5sa8v";
	}}";

	# Symlinks
	"VMs".source = config.lib.file.mkOutOfStoreSymlink "/etc/libvirt/VMs";
	"Mounts".source = config.lib.file.mkOutOfStoreSymlink "/mnt";
      };

      # Define session variables
      home.sessionVariables = {
	EDITOR = "nvim";
	LIBVIRT_DEFAULT_URI = "qemu:///system";
	HISTCONTROL = "ignoreboth";
      };

      # Shell aliases
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;
	initExtra = "${pFetch}";
        oh-my-zsh = {
          enable = true;
	  plugins = [ "git" ];
          theme = "agnoster"; # Main PC
          #theme = "risto"; # Secondary/VM
          #theme = "half-life"; # Server
        };
        shellAliases = {
	  # NixOS aliases
	  nixcfg = "nvim /etc/nixos/{configuration.nix,jimbo.nix}";
          nixswitch = "${auth} nixos-rebuild switch";
          nixdate = "${auth} nix-channel --update; ${auth} nixos-rebuild switch --upgrade";
          nixclean = "${auth} nix-store --gc; nix-collect-garbage -d";

          # Shortcut aliases
          #neo = "clear && neofetch";
	  neo = "clear && neofetch --ascii ~/.config/neofetch/xenia.ascii --ascii_colors 1 7 3 --colors 0 0 0 1 3 7";
	  pfetch = "${pFetch}";
          ip = "ip -c";
          ls = "${pkgs.eza}/bin/eza -a --color=always --group-directories-first";
	  cat = "${pkgs.bat}/bin/bat --paging never";
	  lcat = "${pkgs.bat}/bin/bat";
	  copycat = "wl-copy <";
          sunshinehost = "WAYLAND_DISPLAY=wayland-1 DISPLAY=:1 sunshine -0";
          birth = "date -d @$(stat -c %W /) '+%a %b %d %r %Z %Y'";
	  alarmlist = "cat ${alarmScript}/bin/alarms";
	  remind = "notify-send 'Terminal command finished.'";

          # SSH Commands
          ssh="${ssh}";
          senecassh="ssh jhampton1@matrix.senecacollege.ca";
          dataws="ssh -i ~/.ssh/dat330-first.pem";
          opsrouter="ssh 44.216.132.129";
          opswww="opsrouter -p 2211";
          opsslave1="opsrouter -p 2221";
          opsslave2="opsrouter -p 2222";
          opsslave3="opsrouter -p 2223";

          # Session commands
          swaystart = "${auth} systemctl start greetd";
          swayrestart = "${auth} systemctl restart greetd";
          swaystop = "${auth} systemctl stop greetd";

          # Curl tools
          myip = "curl ifconfig.co";
          weather = "curl wttr.in/Vaughan";

          # Download from YouTube
          ytmp4 = "yt-dlp --recode-video mp4";

          # Personal fixes
          namedisk = "${auth} e2label";

	  # Flakes
	  buildiso = 
	    "nix run github:nix-community/nixos-generators -- -f install-iso -c /etc/nixos/configuration.nix";
        };
      };

      # Define current version
      home.stateVersion = "23.11";
    };
  };
}
