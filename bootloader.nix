{ pkgs, lib, config, ... }:

let
  config_txt = pkgs.writeText "config.txt" ''
    initramfs initrd followkernel
    gpu_mem=16
  '';
in {
  options = {
    boot.loader.rpi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
  config = lib.mkIf config.boot.loader.rpi.enable {
    system.boot.loader.id = "rpi";
    system.build.installBootLoader = pkgs.replaceVars ./reinstall-bootloader.sh {
      crossShell = pkgs.runtimeShell;
      inherit config_txt;
      fw = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
    };
  };
}
