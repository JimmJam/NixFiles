{ config, pkgs, options, ... }:
let
  # Terminal authenticator
  auth = ''doas'';

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

  pFetch = ''neofetch --config $(readlink -f ~/.config/neofetch/small.conf) --ascii_distro debian_small'';

  # Rofi (terminal file browser) config
  rangerConf = ''
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

  # Choose how ranger opens stuff
  rifleConf = ''
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
in

{
  # Define home manager programs and configs
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jimbo = { config, pkgs, ... }: {
      # Install user programs
      home.packages = (with pkgs; [
	neofetch htop ranger
      ]);

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
          highlight Normal guibg=#101010 ctermbg=235
          highlight Visual guibg=#303030 ctermbg=238
          highlight Pmenu guibg=#303030 ctermbg=238
          highlight EndOfBuffer guibg=#101010 ctermbg=235
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

      # Enable tmux
      programs.tmux = {
        enable = true;
	extraConfig = ''
	  set -g mouse on
          set -g base-index 1
          set -g default-terminal "st-256color"
          set -g history-limit 4096
          set -g set-titles on
          set -g set-titles-string "#T"
          set -g status on
	  set -g status-left ""
          set -g status-position bottom
          set -g status-right "#[bg=brightblack]#[fg=dark_purple] #T "
          set -g status-style "bg=black"
          setw -g pane-base-index 1
          setw -g window-status-format "#[bg=brightmagenta]#[fg=black] #I #[bg=brightblack]#[fg=white] #W "
          setw -g window-status-current-format "#[bg=brightmagenta]#[fg=black] #I #[bg=white]#[fg=black] #W "
	'';
      };

      # Start defining arbitrary files
      home.file = {
	# Neofetch config
	".config/neofetch/config.conf".text = neoConf;
	".config/neofetch/small.conf".text = smallConf;

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
          theme = "half-life";
        };
        shellAliases = {
	  # NixOS aliases
	  nixcfg = "nvim /etc/nixos/{configuration.nix,jimbo.nix}";
          nixswitch = "${auth} nixos-rebuild switch";
          nixdate = "${auth} nix-channel --update; ${auth} nixos-rebuild switch --upgrade";
          nixclean = "${auth} nix-store --gc; nix-collect-garbage -d";

          # Shortcut aliases
          neo = "clear && neofetch --ascii_distro debian";
	  pfetch = "${pFetch}";
          ip = "ip -c";
          ls = "${pkgs.eza}/bin/eza -a --color=always --group-directories-first";
	  cat = "${pkgs.bat}/bin/bat --paging never";
	  lcat = "${pkgs.bat}/bin/bat --paging always";
          birth = "date -d @$(stat -c %W /) '+%a %b %d %r %Z %Y'";

          # Curl tools
          myip = "curl ifconfig.co";
          weather = "curl wttr.in/Vaughan";

          # Personal fixes
          namedisk = "${auth} e2label";

	  # Start basic programs
	  controlpanel = "tmux new-session -d -s control; tmux attach -t control";
	  ducksync = "~/.config/duckdns/duck.sh";

	  # Minecraft stuff
          mineservers = "cd /home/jimbo/JimboNFS/MineServers";
          mcstart21 = "${pkgs.temurin-jre-bin-21}/bin/java -Xms9G -Xmx9G -jar";
          mcstart8 = "${pkgs.temurin-jre-bin-21}/bin/java -Xms5G -Xmx5G -jar";
          johnstart = "mineservers; cd Johnside-SMP && mcstart21 paper* --nogui";
          betastart = "mineservers; cd BetaServer && mcstart8 Posiden*";
        };
      };

      # Define current version
      home.stateVersion = "23.11";
    };
  };
}
