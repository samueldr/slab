{ config, lib, pkgs, ... }:

let
  cfg = config.services.slab;
in {
  options.services.slab = {
    ttyNumber = lib.mkOption {
      type = lib.types.str;
      default = "2";
    };
    userName =  lib.mkOption {
      type = lib.types.str;
      default = "dan";
    };
  };
  config = {
    nixpkgs.overlays = [ (import ./overlay.nix) ] ;

    environment.systemPackages = with pkgs; [
      chatty
      squeekboardService
      firefoxMobile
      launcher
      gnome3.adwaita-icon-theme
    ];

    services.dbus.packages = [ pkgs.squeekboardService ];
    services.logind.extraConfig = ''
      HandlePowerKey=suspend
      IdleAction=suspend
      IdleActionSec=2min
    '';

    programs.sway = {
      enable = true;
      extraPackages = with pkgs; [
        swaylock swayidle xwayland termite
        mako grim slurp wl-clipboard wf-recorder
      ];
    };

    programs.calls.enable = true;

    # this is seven kinds of convoluted, I can only assume because
    # GNOME developers like to cosplay as enterprise admin software
    # developers
    programs.dconf =
      let profile = pkgs.writeText "user" ''
         user-db:user
         system-db:slab
         ''; in
        {
          enable = true;
          profiles.user = ( builtins.toPath profile);
          packages =
            let squeekboardSetting = pkgs.stdenv.mkDerivation {
                  name="squeekboard-conf";
                  phases = ["installPhase"];
                  installPhase = ''
                    d=$out/etc/dconf/db/slab.d
                    mkdir -p $d
                    echo -e "[org/gnome/desktop/a11y/applications]\nscreen-keyboard-enabled=true" > $d/file
                ''    ;
                };
            in [ squeekboardSetting ];
        };

    systemd.defaultUnit = "graphical.target";

    systemd.services.sway = {
      enable = true;

      # these dependencies are copied from display-manager.service on
      # a GNOME machine. They work for me, but may or may not be
      # entirely optimal
      wants = [
        "systemd-machined.service"
        "accounts-daemon.service"
        "systemd-udev-settle.service"
        "dbus.socket"
      ];
      aliases = [ "display-manager.service" ];
      after =  [
        "rc-local.service"
        "systemd-machined.service"
        "systemd-user-sessions.service"
        "getty@tty${cfg.ttyNumber}.service"
        "plymouth-quit.service"
        "plymouth-start.service"
        "systemd-logind.service"
        "systemd-udev-settle.service"
      ];
      conflicts = [
        "getty@tty${cfg.ttyNumber}.service"
        "plymouth-quit.service"
      ];

      serviceConfig =
        let run-sway = pkgs.writeScript "run-sway" ''
          #!${pkgs.bash}/bin/bash
          source ${config.system.build.setEnvironment}
          ${pkgs.dbus}/bin/dbus-run-session ${pkgs.launcher}/bin/launch
          systemd-cat echo "dbus-run-session $?"
        '';
        in {
#          ExecStartPre = "${config.system.path}/bin/chvt 6";
          ExecStart = run-sway;
          TTYPath = "/dev/tty${cfg.ttyNumber}";
          TTYReset = "yes";
          TTYVHangup = "yes";
          TTYVTDisallocate = "yes";
          PAMName = "login";
          User = cfg.userName;
          WorkingDirectory = "/home/${cfg.userName}";
          StandardInput = "tty";
          StandardError = "journal";
          StandardOutput = "journal";
          Restart = "no";
          SyslogIdentifier = "sway";
        };
    };

    # waybar needs one or more of these for icons
    fonts.fonts = with pkgs; [ font-awesome font-awesome-ttf ] ;

    networking.wireless.enable = false;

    networking.networkmanager.enable = true;
    networking.networkmanager.unmanaged = [ "rndis0" "usb0" ];


    # XXX need to tighten these down, all we really need is to
    # be able to write some sysfs files
    security.wrappers = {
      pptk-backlight = {
        setuid = true; owner = "root"; group = "root";
        source = "${pkgs.pinephone-toolkit}/bin/pptk-backlight";
      };
      pptk-cpu-sleep =  {
        setuid = true; owner = "root"; group = "root";
        source = "${pkgs.pinephone-toolkit}/bin/pptk-cpu-sleep";
      };
      pptk-led =  {
        setuid = true; owner = "root"; group = "root";
        source = "${pkgs.pinephone-toolkit}/bin/pptk-led";
      };
      pptk-vibrate =  {
        setuid = true; owner = "root"; group = "root";
        source = "${pkgs.pinephone-toolkit}/bin/pptk-vibrate";
      };
    };
  };
}
