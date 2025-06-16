# Nix on MacOS

How to install nix, use nix-darwin and flakes.


## Install nix

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```
[https://nixos.org/download/](https://nixos.org/download/)

## Initialize flake for nix-darwin

```bash
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```

## Run and build using nix-darwin

```bash
sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake .config/nix#mac
```
### rebuild

```bash
sudo darwin-rebuild switch --flake ~/.config/nix#mac
```

## nix-darwin flake


[https://raw.githubusercontent.com/NimaSaed/dotfiles/refs/heads/master/nix/flake.nix](https://raw.githubusercontent.com/NimaSaed/dotfiles/refs/heads/master/nix/flake.nix)

```nix
{
  description = "Mac nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.bash
          pkgs.git
          pkgs.jq
          pkgs.tmux
          pkgs.bat
          pkgs.fzf
          pkgs.gnused
          pkgs.vim
          pkgs.alacritty
          pkgs.aerospace
          pkgs.brave
          pkgs.logseq
          #pkgs.teams
          pkgs.monitorcontrol
          pkgs.openscad
          pkgs.slack
          pkgs.podman
          pkgs.openfga
          pkgs.openfga-cli
          pkgs.mkalias
        ];

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "coreutils"
        ];
        casks = [
          "1password"
          "1password-cli"
          "basictex"
          "burp-suite-professional"
          "grammarly-desktop"
          "parallels"
          "font-jetbrains-mono"
          "bambu-studio"
          "qflipper"
          "microsoft-teams"
        ];
        masApps = {
          "ikea desk remote" = 1509037746;
          "1password for safari" = 1569813296;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock.autohide = true;
        dock.orientation = "left";
        dock.autohide-delay = 1000.0;
        dock.show-recents = false;
        dock.tilesize = 24;
        dock.expose-group-apps = true;
        dock.persistent-apps = [
          "${pkgs.alacritty}/Applications/Alacritty.app"
          "/Applications/Safari.app"
          "${pkgs.slack}/Applications/Slack.app"
          "${pkgs.teams}/Applications/Teams.app"
        ];
        finder.FXPreferredViewStyle = "clmv";
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";

        loginwindow.GuestEnabled = false;
      };

      security.pam.services.sudo_local.touchIdAuth = true;
      security.pam.services.sudo_local.reattach = true;
      security.pam.services.sudo_local.watchIdAuth = true;

      #system.autoupgrade.enable = true;
      #system.autoUpgrade.enable = true;
      #system.autoupgrade.dates = "weekly";

      nix.gc.automatic = true;
      nix.gc.interval = [
        {
          Hour = 3;
          Minute = 15;
          Weekday = 7;
        }
      ];
      nix.gc.options = "--delete-older-than 10d";
      nix.optimise.automatic = true;


      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.bash.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "nima";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # apple silicon only
            enableRosetta = true;
            # User owning the homebrew prefix
            user = "nima";
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
```


