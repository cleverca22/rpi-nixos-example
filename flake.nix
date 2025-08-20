{
  outputs = { nixpkgs, self }:
  let
    configuration = { config, pkgs, lib, ... }:
    {
      imports = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
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
      users.users.pi = {
        extraGroups = [ "wheel" ];
        initialPassword = "hunter2";
        isNormalUser = true;
      };
      sdImage = {
        firmwareSize = 64;
        populateFirmwareCommands = let
          fw = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
          cmdline = pkgs.writeText "cmdline.txt" ''
            init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}
          '';
          config_txt = pkgs.writeText "config.txt" ''
            initramfs initrd followkernel
            gpu_mem=16
          '';
        in ''
          cp -v ${fw}/{bootcode.bin,fixup.dat,start.elf,fixup4.dat,start4.elf,fixup4cd.dat,fixup_cd.dat,start4cd.elf,start_cd.elf,bcm2710*dtb,bcm2711*dtb,bcm2712*dtb} firmware/
          cat ${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile} | gzip -9v > firmware/kernel8.img
          cp -v ${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile} firmware/initrd
          cp -v ${cmdline} firmware/cmdline.txt
          cp -v ${config_txt} firmware/config.txt
        '';
        populateRootCommands = ''
        '';
      };
    };
    eval = nixpkgs.legacyPackages.aarch64-linux.nixos configuration;
  in
  {
    packages.aarch64-linux = {
      nixos = eval.config.system.build.toplevel;
      sdImage = eval.config.system.build.sdImage;
      inherit eval;
    };
  };
}
