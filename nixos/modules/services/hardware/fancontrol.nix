{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.fancontrol;
  configFile = pkgs.writeText "fancontrol.conf" cfg.config;

in
{
  options.hardware.fancontrol = {
    enable = lib.mkEnableOption "software fan control (requires fancontrol.config)";

    config = lib.mkOption {
      type = lib.types.lines;
      description = "Required fancontrol configuration file content. See {manpage}`pwmconfig(8)` from the lm_sensors package.";
      example = ''
        # Configuration file generated by pwmconfig
        INTERVAL=10
        DEVPATH=hwmon3=devices/virtual/thermal/thermal_zone2 hwmon4=devices/platform/f71882fg.656
        DEVNAME=hwmon3=soc_dts1 hwmon4=f71869a
        FCTEMPS=hwmon4/device/pwm1=hwmon3/temp1_input
        FCFANS=hwmon4/device/pwm1=hwmon4/device/fan1_input
        MINTEMP=hwmon4/device/pwm1=35
        MAXTEMP=hwmon4/device/pwm1=65
        MINSTART=hwmon4/device/pwm1=150
        MINSTOP=hwmon4/device/pwm1=0
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.fancontrol = {
      documentation = [ "man:fancontrol(8)" ];
      description = "software fan control";
      wantedBy = [ "multi-user.target" ];
      after = [ "lm_sensors.service" ];

      serviceConfig = {
        Restart = "on-failure";
        ExecStart = "${lib.getExe' pkgs.lm_sensors "fancontrol"} ${configFile}";
      };
    };

    # On some systems, the fancontrol service does not resume properly after sleep because the pwm status of the fans
    # is not reset properly. Restarting the service fixes this, in accordance with https://github.com/lm-sensors/lm-sensors/issues/172.
    powerManagement.resumeCommands = ''
      systemctl restart fancontrol.service
    '';

  };

  meta.maintainers = [ lib.maintainers.evils ];
}
