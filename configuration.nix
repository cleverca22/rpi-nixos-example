{ ... }:

{
  imports = [ ./hardware-configuration.nix ];
  users.users.pi = {
    extraGroups = [ "wheel" ];
    initialPassword = "hunter2";
    isNormalUser = true;
  };
  services.openssh.enable = true;
}
