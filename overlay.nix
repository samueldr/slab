self: super: {
  # https://github.com/NixOS/nixpkgs/issues/153304
  alacritty = super.alacritty.overrideAttrs (
    o: rec {
      doCheck = false;
    }
  );

  firefoxMobile = self.callPackage ./pkgs/mobile-firefox {};

  # this is, with hindsight, not a great name
  launcher = self.callPackage ./pkgs/launcher {};

  megi-call-audio = self.callPackage ./pkgs/megi-call-audio {};

  netsurf = self.callPackage ./pkgs/netsurf {};

  pinephone-toolkit = self.stdenv.mkDerivation {
    name = "pinephone-toolkit";

    nativeBuildInputs = with self.pkgs; [
      meson ninja pkg-config
    ];
    version = "0deaf8473";
    src = self.fetchFromGitHub {
      owner = "Dejvino";
      repo = "pinephone-toolkit";
      rev = "0deaf8473a81670298e2bc5772c99d4bae68ffd5";
      hash = "sha256-u6C79xLeA/m9/3LroA2DF6qQ7COun0m4pBylLIFnMcI=";
    };
  };

  saturn = self.callPackage ./pkgs/saturn {};

  squeekboard = self.callPackage ./pkgs/squeekboard {};

  squeekboardService = self.stdenv.mkDerivation {
    name = "squeekboard.service";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/share/dbus-1/services
      cat <<EOF > $out/share/dbus-1/services/sm.puri.OSK0.service
      [D-BUS Service]
      Name=sm.puri.OSK0
      Exec=${self.squeekboard}/bin/squeekboard
      EOF
    '';
  };

  # CHECK do we need this? the .session file is installed elsewhere
  squeekboardXml = builtins.fetchurl {
    url = "https://source.puri.sm/Librem5/squeekboard/-/raw/4efe57cbb4f4f0427839a9142001dcc5450acaf2/data/dbus/sm.puri.OSK0.xml";
    name = "sm.puri.OSK0.xml";
    sha256 = "1jpsy5aj9wkb3pjgsdc2scamx91awa7q0bzpxz986fj7jw7dkllp";
  };
}
