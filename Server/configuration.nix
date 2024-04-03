{ config, pkgs, options, lib, ... }: 
let
  # Import home manager
  homeManager = fetchTarball 
    "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";

  # Define domains and ips
  domain = ''jimbosfiles.duckdns.org'';

  # IPs
  localspan = ''192.168.1'';
  pc = ''${localspan}.18'';
  server = ''${localspan}.17'';
  laptop = ''${localspan}.45'';
  vm = ''${localspan}.70'';
  ps4 = ''${localspan}.183'';
in

{
  # Import other nix files and firmware
  imports = [ 
    ./hardware-configuration.nix
    ./jimbo.nix 
    "${homeManager}/nixos"
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
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };

  # Enable a permissioning system
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
	# Give wheel root access, allow persistant session
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLe/HioxCOkszFQdm1vb3ZwuzLzsOThqHNvEI4IXeXZ JimPhone"
    ];
    extraGroups = [ "wheel" ];
    uid = 1000;
    shell = pkgs.zsh;
  };

  # Installed programs to the system profile.
  environment.systemPackages = with pkgs; [
    # Essential system tools
    git parted mdadm
  ];

  # Disable the HTML documentation link
  documentation = {
    nixos.enable = false;
    info.enable = false;
  };

  # Define timezone and networking settings
  time.timeZone = "America/New_York";
  networking = {
    # Set hostname
    hostName = "JimNixServer";

    # Choose networking method
    dhcpcd.enable = true;
    wireless.enable = false;
    
    # Enable firewall passthrough
    firewall = {
      allowedTCPPorts = [ 
	# SSH
	2222

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
	25565 30000 30005

	# Gitea
	3110 2299
      ];
      allowedUDPPorts = [
        # AdGuard
	53

	# Minecraft Voicechat and Bedrock
	24454 19132
      ];

      # Services forwarded to my PC or VM
      extraCommands = ''
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 2211 -m comment --comment "SSH to PC" -j DNAT --to-destination ${pc}:2211
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 2215 -m comment --comment "SSH to VM" -j DNAT --to-destination ${vm}:2215
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9060 -m comment --comment "PC Cockpit" -j DNAT --to-destination ${pc}:9090
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 8182 -m comment --comment "Qbittorrent" -j DNAT --to-destination ${pc}:8182
        iptables -t nat -A PREROUTING -p udp -m udp --dport 27005 -m comment --comment "Half-Life" -j DNAT --to-destination ${pc}:27005
        iptables -t nat -A PREROUTING -p udp -m udp --dport 27015 -m comment --comment "Half-Life" -j DNAT --to-destination ${pc}:27015
        iptables -t nat -A PREROUTING -p udp -m udp --dport 7777 -m comment --comment "Lethal Company" -j DNAT --to-destination ${pc}:7777
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
      '' +

      # PlayStation Remote Play
      ''
        iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9295 -m comment --comment "TCP Bit" -j DNAT --to-destination ${ps4}:9295
        iptables -t nat -A PREROUTING -p udp -m udp --dport 9296 -m comment --comment "UDP Bit 1" -j DNAT --to-destination ${ps4}:9296
        iptables -t nat -A PREROUTING -p udp -m udp --dport 9297 -m comment --comment "UDP Bit 2" -j DNAT --to-destination ${ps4}:9297
      '';
      allowPing = false;
    };
    extraHosts = ''
      ${pc} pc
      ${server} server
      ${laptop} laptop
      ${vm} vm
      ${ps4} ps4
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
      settings = {
        LogLevel = "VERBOSE";
	PermitRootLogin = "no";
      };
      ports = [ 2222 ];
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
        /export/JimboNFS ${localspan}.0/24(rw,nohide,insecure,no_subtree_check)
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

        # Bluemap
        "bluemap.${domain}".extraConfig = ''
          reverse_proxy http://127.0.0.1:30001
        '';
        
        # Gitea
        "git.${domain}".extraConfig = ''
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

    # Gitea
    gitea = {
      enable = true;
      settings.server = {
	DOMAIN = "git.jimbosfiles.duckdns.org";
	ROOT_URL = "https://git.jimbosfiles.duckdns.org:443";
        HTTP_PORT = 3110;
	SSH_PORT = 2299;
	START_SSH_SERVER = true;
	DISABLE_REGISTRATION = true;
      };
    };

    # Snowflake proxy for helping Tor
    snowflake-proxy.enable = true;

    # Fix a stupid non building issue
    logrotate.checkConfig = false;
  };

  # Determine the release version and allow auto-upgrades
  system.stateVersion = "23.11";
  system.autoUpgrade.enable = false;
}
