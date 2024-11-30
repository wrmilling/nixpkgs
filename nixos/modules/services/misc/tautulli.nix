{ config, pkgs, lib, ... }:
let
  cfg = config.services.tautulli;
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "plexpy" ] [ "services" "tautulli" ])
  ];

  options = {
    services.tautulli = {
      enable = lib.mkEnableOption "Tautulli Plex Monitor";

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/plexpy";
        description = "The directory where Tautulli stores its data files.";
      };

      configFile = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/plexpy/config.ini";
        description = "The location of Tautulli's config file.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8181;
        description = "TCP port where Tautulli listens.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open ports in the firewall for Tautulli.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "plexpy";
        description = "User account under which Tautulli runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "nogroup";
        description = "Group under which Tautulli runs.";
      };

      package = lib.mkPackageOption pkgs "tautulli" { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.tautulli = {
      description = "Tautulli Plex Monitor";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        GuessMainPID = "false";
        ExecStart = "${cfg.package}/bin/tautulli --datadir ${cfg.dataDir} --config ${cfg.configFile} --port ${toString cfg.port} --pidfile ${cfg.dataDir}/tautulli.pid --nolaunch";
        Restart = "on-failure";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    users.users = lib.mkIf (cfg.user == "plexpy") {
      plexpy = { group = cfg.group; uid = config.ids.uids.plexpy; };
    };
  };
}
