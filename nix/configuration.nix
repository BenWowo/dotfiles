# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hp-printer-nix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.gdm.autoSuspend = false;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    uv
    eza
    git
    fzf
    tmux
    wget
    tailscale
    gh
    bun
    zoxide
    gdb
    gnumake
    gcc
    file
    ffmpeg
    zip
    unzip
    croc
    yazi
    bat
    wl-clipboard
    bind
  ];
  environment.enableAllTerminfo = true;
  environment.variables = {
	EDITOR="nvim";
	VISUAL="nvim";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.zoxide.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      y() {
        local tmp cwd
        tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d "" cwd < "$tmp" || true
  
        if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
          builtin cd -- "$cwd"
        fi
  
        command rm -f -- "$tmp"
      }
    '';
  
    shellAliases = {
      ls = "exa";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
    };
  
    promptInit = ''
      PS1='\[\e[1;32m\][\u@\h:\w]\$\[\e[0m\] '
    '';
  };
  programs.neovim = {
	enable = true;
	configure.customRC = ''
		set number
		set clipboard=unnamedplus

		if !empty($SSH_CONNECTION)
			let g:clipboard = 'osc52'
		endif
	'';
  };

  # List services that you want to enable:
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the tailscale deamon.
  services.tailscale.enable = true;

  # Make the laptop not go to sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  systemd.targets.suspend-then-hibernate.enable = false;

  # Keep laptop running whtn plugged in
  # services.logind.lidSwitch = "suspend";
  # services.logind.lidSwitchExternalPower = "ignore";
  # -- These configurations seem to not be doing anything --
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  # Disable automatic suspend in GNOME user sessions.
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      lockAll = true;
      settings."org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };
    }
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
