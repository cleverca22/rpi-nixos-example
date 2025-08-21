{ pkgs, config, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image.nix"

    # TODO, upstream nixos/lib/make-ext4-fs.nix doesnt leave enough inodes
    # resulting in an image that fails the first boot
    #"${modulesPath}/installer/cd-dvd/channel.nix"
  ];
  boot = {
    postBootCommands = ''
      if ! [ -e /etc/nixos/hardware-configuration.nix ]; then
        mkdir -pv /etc/nixos/
        pushd /etc/nixos/
        cp ${./configuration.nix} configuration.nix
        cp ${./hardware-configuration.nix} hardware-configuration.nix
        cp ${./bootloader.nix} bootloader.nix
        cp ${./reinstall-bootloader.sh} reinstall-bootloader.sh
        popd
        rm /root/.nix-defexpr/channels
      fi
    '';
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
}
