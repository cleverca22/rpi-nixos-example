{ pkgs, config, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image.nix"
    ./bootloader.nix
  ];
  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    loader = {
      grub.enable = false;
    };
  };
  fileSystems = {
    "/boot/firmware" = {
      label = "FIRMWARE";
    };
    "/" = {
      label = "NIXOS_SD";
      fsType = "ext4";
    };
  };
  hardware.enableAllHardware = lib.mkForce false;
}
