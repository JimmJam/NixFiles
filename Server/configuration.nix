{ config, pkgs, options, lib, ... }: 
let
  # Import home manager
  home-manager = fetchTarball 
    "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";

  # Define domains and ips
  domain = ''jimbosfiles.duckdns.org'';

  # IPs
  localspan = ''192.168.1'';
  pc = ''${localspan}.18'';
  server = ''${localspan}.17'';
  laptop = ''${localspan}.45'';
  vm = ''${localspan}.70'';
in

{
  # Import other nix files and firmware
  imports = [ 
    ./hardware-configuration.nix ./jimbo.nix (import "${home-manager}/nixos")
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow flakes (I have no clue how they work yet)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree firmware
  hardware.enableRedistributableFirmware = true;

  # Choose Grub as the bootloader
  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };

  # Create the sudoers file
  security = {
    sudo.enable = false;
    doas = {
    enable = true;
      extraRules = [
	# Allow anyone in admin to execute as root, and allow a persistant session
        { groups = [ "wheel" ]; keepEnv = true; persist = true; }
      ];
    };
  };

  # Enable ZSH as a possible shell for users
  programs.zsh.enable = true;

  # Define a user account.
  users.users.jimbo = {
    isNormalUser = true;
    hashedPassword = 
      "$6$gYpE.pG/zPXgin06$2kydjDfd0K62Dhf9P0PFvJhRNz6xIC/bHYaf/XYqyKcLyZNzPQpy8uy9tCRcSYlj1wwBhzVtTRyItwajOHCEj0";
    extraGroups = [ "wheel" ];
    uid = 1000;
    shell = pkgs.zsh;
  };

  # Installed programs to the system profile.
  environment.systemPackages = with pkgs; [
    # Essential system tools
    git parted certbot
  ];

  # Disable the HTML documentation link
  documentation.nixos.enable = false;

  # Define timezone and networking settings
  time.timeZone = "America/New_York";
  networking = let
    localspan = ''192.168.1'';
  in {
    hostName = "JimDebianServer";
    dhcpcd.enable = true;
    wireless.enable = false;
    firewall = {
      allowedTCPPorts = [ 
	# SSH
	22

	# NFS
	2049

	# Caddy
        80 443

	# Cockpit
	9090

	# Vaultwarden
	8222

	# AdGuard
	3000

	# Minecraft
	25565

	# Synapse
	8448 8008

	# Gitea
	3110 2222
      ];
      allowedUDPPorts = [
        # AdGuard
	53

	# Minecraft Voicechat
	24454
      ];
      # Services forwarded to my PC or VM
      extraCommands = ''
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 2211 -m comment --comment "SSH to PC" -j DNAT --to-destination ${pc}:22
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 2215 -m comment --comment "SSH to VM" -j DNAT --to-destination ${vm}:22
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9060 -m comment --comment "PC Cockpit" -j DNAT --to-destination ${pc}:9090
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 8182 -m comment --comment "Qbittorrent" -j DNAT --to-destination ${pc}:8182
        iptables -t nat -A PREROUTING -p udp -m udp --dport 27005 -m comment --comment "Half-Life" -j DNAT --to-destination ${pc}:27005
        iptables -t nat -A PREROUTING -p udp -m udp --dport 27015 -m comment --comment "Half-Life" -j DNAT --to-destination ${pc}:27015
      '' +
      # Sunshine ports for PC and VM
      ''
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 48010 -m comment --comment "PC Sunshine RTSP" -j DNAT --to-destination ${pc}:48010
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 47989 -m comment --comment "PC Sunshine HTTP" -j DNAT --to-destination ${pc}:47989
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 47984 -m comment --comment "PC Sunshine HTTPS" -j DNAT --to-destination ${pc}:47984
        iptables -t nat -A PREROUTING -p udp -m udp --dport 47998 -m comment --comment "PC Sunshine Video" -j DNAT --to-destination ${pc}:47998
        iptables -t nat -A PREROUTING -p udp -m udp --dport 47999 -m comment --comment "PC Sunshine Control" -j DNAT --to-destination ${pc}:47999
        iptables -t nat -A PREROUTING -p udp -m udp --dport 48000 -m comment --comment "PC Sunshine Audio" -j DNAT --to-destination ${pc}:48000
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 38010 -m comment --comment "VM Sunshine RTSP" -j DNAT --to-destination ${vm}:38010
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 37989 -m comment --comment "VM Sunshine HTTP" -j DNAT --to-destination ${vm}:37989
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 37984 -m comment --comment "VM Sunshine HTTPS" -j DNAT --to-destination ${vm}:37984
        iptables -t nat -A PREROUTING -p udp -m udp --dport 37998 -m comment --comment "VM Sunshine Video" -j DNAT --to-destination ${vm}:37998
        iptables -t nat -A PREROUTING -p udp -m udp --dport 37999 -m comment --comment "VM Sunshine Control" -j DNAT --to-destination ${vm}:37999
        iptables -t nat -A PREROUTING -p udp -m udp --dport 38000 -m comment --comment "VM Sunshine Audio" -j DNAT --to-destination ${vm}:38000
	iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
      '';
      allowPing = false;
    };
    extraHosts = ''
      ${pc} pc
      ${server} server
      ${laptop} laptop
      ${vm} vm
    '';
    nameservers = [ 
      "1.1.1.1"
      "9.9.9.9" 
    ];
  };

  # Boot with compatibility for IP forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Enable AppArmor
  security.apparmor.enable = true;

  # Enable all manner of services
  services = {
    # SSH
    openssh = {
      enable = true;
      settings.LogLevel = "VERBOSE";
    };

    # Login attempt lockout
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [ "${pc}" "${server}" "${vm}" ];
    };

    # Cron
    cron = {
      enable = true;
      systemCronJobs = [
	# Resync DuckDNS ip
        "0 3 * * * jimbo ~/.config/duckdns/duck.sh"
      ];
    };

    # NFS server
    nfs.server = {
      enable = true;
      exports = ''
        /export/JimboNFS ${pc}(rw,nohide,insecure,no_subtree_check) ${laptop}(rw,nohide,insecure,no_subtree_check)
      '';
    };

    # Caddy reverse proxy
    caddy = {
      enable = true;
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      virtualHosts = {
        # Nextcloud Subdomain and TLS Setup
        "${domain}".extraConfig = ''
          redir /.well-known/carddav /remote.php/dav 301
          redir /.well-known/caldav /remote.php/dav 301
          reverse_proxy http://127.0.0.1:8080
        '';

	# Cockpit on PC
	"cockpit.${domain}".extraConfig = ''
	  reverse_proxy ${pc}:9090 {
	    transport http {
	      tls_insecure_skip_verify
	    }
	  }
	'';
          
        # Vaultwarden
        "warden.${domain}".extraConfig = ''
          reverse_proxy 127.0.0.1:8222
        '';

        # AdGuard
        "adguard.${domain}".extraConfig = ''
          reverse_proxy 127.0.0.1:3000
        '';

        # Recipes
        "recipes.${domain}".extraConfig = ''
          reverse_proxy 127.0.0.1:5030
        '';

        # Matrix
        "matrix.${domain}".extraConfig = ''
          reverse_proxy 127.0.0.1:8448
        '';
	"${domain}:8008".extraConfig = ''
	  reverse_proxy 127.0.0.1:8448
	'';

	# Element
	"element.${domain}".extraConfig = ''
	  root * ${pkgs.element-web}
	  file_server
	'';

        # Bluemap
        "bluemap.${domain}".extraConfig = ''
          reverse_proxy http://127.0.0.1:30001
        '';
        
        # Gitea
        "gitea.${domain}".extraConfig = ''
          reverse_proxy http://127.0.0.1:3110
        '';
        
        # Torrent
        "torrent.${domain}".extraConfig = ''
          reverse_proxy http://${domain}:8182
        '';
      };
    };

    # Nextcloud server
    nextcloud = {
      enable = true;
      hostName = "localhost";
      datadir = "/mnt/nextcloud";
      https = true;
      config = {
        adminuser = "jimbo";
        adminpassFile = "/mnt/nextcloud/password.txt";
        overwriteProtocol = "https";
	extraTrustedDomains = [ "${domain}" ];
	trustedProxies = [ "127.0.0.1" ];
      };
    };

    # Force Nextcloud to use a different port
    nginx.virtualHosts."localhost" = {
      listen = [ { addr = "127.0.0.1"; port = 8080; } ];
    };

    # Vaultwarden password manager
    vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://warden.${domain}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
      };
    };

    # Adguard (PiHole alternative)
    adguardhome = {
      enable = true;
      openFirewall = true;
    };

    # Recipes
    tandoor-recipes = {
      enable = true;
      port = 5030;
    };

    # Snowflake proxy for helping Tor
    snowflake-proxy.enable = true;

    # Synapse for Matrix clients
    matrix-synapse = {
      enable = true;
      settings = {
        server_name = "matrix.${domain}";
	public_baseurl = "https://${domain}:8008";
	serve_server_wellknown = true;

	# Set the network config
	listeners = [{
	  port = 8448;
	  tls = false;
	  type = "http";
	  x_forwarded = true;
	  bind_addresses = [ "127.0.0.1" "server" ];
	  resources = [{
	    names = [ "client" "federation" ];
	    compress = true;
	  }];
	}];

	# Set the type of database
	database.name = "sqlite3";

	# Allow account registration
	#enable_registration = true;
	#enable_registration_without_verification = true;
	#macaroon_secret_key = "SillyBilly";

	# Enable image previews
	url_preview_enabled = true;

	# Enable user presence
	presence.enabled = true;

	# Raise upload limit
	max_upload_size = "200M";

	# Disable telemetry
	report_stats = false;
      };
    };

    # Jisti
    jitsi-meet = {
      enable = true;
      nginx.enable = false;
      caddy.enable = true;
      hostName = "jitsi.${domain}";
    };

    # Gitea
    gitea = {
      enable = true;
      settings.server = {
	DOMAIN = "gitea.jimbosfiles.duckdns.org";
	ROOT_URL = "https://gitea.jimbosfiles.duckdns.org:443";
        HTTP_PORT = 3110;
	SSH_PORT = 2222;
	START_SSH_SERVER = true;
	DISABLE_REGISTRATION = true;
      };
    };
  };

  # Configure the Element web server
  nixpkgs.config.element-web.conf = {
    default_server_config = {
      "m.homeserver" = {
        base_url = "https://${domain}:8008";
        server_name = "matrix.${domain}";
      };
    };
    jitsi = {
      preferred_domain = "jitsi.${domain}";
    };
    disable_custom_urls = true;
    disable_guests = true;
    show_labs_settings = true;
    default_theme = "dark";
  };


  # Determine the release version and allow auto-upgrades
  system.stateVersion = "23.11";
  system.autoUpgrade.enable = false;
}
