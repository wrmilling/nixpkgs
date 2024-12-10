{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  smbToString = x: if builtins.typeOf x == "bool" then boolToString x else toString x;

  cfg = config.services.samba;

  samba = cfg.package;

  shareConfig =
    name:
    let
      share = getAttr name cfg.shares;
    in
    "[${name}]\n "
    + (smbToString (map (key: "${key} = ${smbToString (getAttr key share)}\n") (attrNames share)));

  configFile = pkgs.writeText "smb.conf" (
    if cfg.configText != null then
      cfg.configText
    else
      ''
        [global]
        security = ${cfg.securityType}
        passwd program = /run/wrappers/bin/passwd %u
        invalid users = ${smbToString cfg.invalidUsers}

        ${cfg.extraConfig}

        ${smbToString (map shareConfig (attrNames cfg.shares))}
      ''
  );

  # This may include nss_ldap, needed for samba if it has to use ldap.
  nssModulesPath = config.system.nssModules.path;

  daemonService = appName: args: {
    description = "Samba Service Daemon ${appName}";

    after = [
      (mkIf (cfg.enableNmbd && "${appName}" == "smbd") "samba-nmbd.service")
      "network.target"
    ];
    requiredBy = [ "samba.target" ];
    partOf = [ "samba.target" ];

    environment = {
      LD_LIBRARY_PATH = nssModulesPath;
      LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";
    };

    serviceConfig = {
      ExecStart = "${samba}/sbin/${appName} --foreground --no-process-group ${args}";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      LimitNOFILE = 16384;
      PIDFile = "/run/${appName}.pid";
      Type = "notify";
      NotifyAccess = "all"; # may not do anything...
    };
    unitConfig.RequiresMountsFor = "/var/lib/samba";

    restartTriggers = [ configFile ];
  };

in

{
  imports = [
    (mkRemovedOptionModule [ "services" "samba" "defaultShare" ] "")
    (mkRemovedOptionModule [ "services" "samba" "syncPasswordsByPam" ]
      "This option has been removed by upstream, see https://bugzilla.samba.org/show_bug.cgi?id=10669#c10"
    )
  ];

  ###### interface

  options = {

    # !!! clean up the descriptions.

    services.samba = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Samba, which provides file and print
          services to Windows clients through the SMB/CIFS protocol.

          ::: {.note}
          If you use the firewall consider adding the following:

              services.samba.openFirewall = true;
          :::
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to automatically open the necessary ports in the firewall.
        '';
      };

      enableNmbd = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable Samba's nmbd, which replies to NetBIOS over IP name
          service requests. It also participates in the browsing protocols
          which make up the Windows "Network Neighborhood" view.
        '';
      };

      enableWinbindd = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable Samba's winbindd, which provides a number of services
          to the Name Service Switch capability found in most modern C libraries,
          to arbitrary applications via PAM and ntlm_auth and to Samba itself.
        '';
      };

      package = mkPackageOption pkgs "samba" {
        example = "samba4Full";
      };

      invalidUsers = mkOption {
        type = types.listOf types.str;
        default = [ "root" ];
        description = ''
          List of users who are denied to login via Samba.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Additional global section and extra section lines go in here.
        '';
        example = ''
          guest account = nobody
          map to guest = bad user
        '';
      };

      configText = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = ''
          Verbatim contents of smb.conf. If null (default), use the
          autogenerated file from NixOS instead.
        '';
      };

      securityType = mkOption {
        type = types.enum [
          "auto"
          "user"
          "domain"
          "ads"
        ];
        default = "user";
        description = "Samba security type";
      };

      nsswins = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to enable the WINS NSS (Name Service Switch) plug-in.
          Enabling it allows applications to resolve WINS/NetBIOS names (a.k.a.
          Windows machine names) by transparently querying the winbindd daemon.
        '';
      };

      shares = mkOption {
        default = { };
        description = ''
          A set describing shared resources.
          See {command}`man smb.conf` for options.
        '';
        type = types.attrsOf (types.attrsOf types.unspecified);
        example = literalExpression ''
          { public =
            { path = "/srv/public";
              "read only" = true;
              browseable = "yes";
              "guest ok" = "yes";
              comment = "Public samba share.";
            };
          }
        '';
      };

    };

  };

  ###### implementation

  config = mkMerge [
    {
      assertions = [
        {
          assertion = cfg.nsswins -> cfg.enableWinbindd;
          message = "If samba.nsswins is enabled, then samba.enableWinbindd must also be enabled";
        }
      ];
      # Always provide a smb.conf to shut up programs like smbclient and smbspool.
      environment.etc."samba/smb.conf".source = mkOptionDefault (
        if cfg.enable then configFile else pkgs.writeText "smb-dummy.conf" "# Samba is disabled."
      );
    }

    (mkIf cfg.enable {

      system.nssModules = optional cfg.nsswins samba;
      system.nssDatabases.hosts = optional cfg.nsswins "wins";

      systemd = {
        targets.samba = {
          description = "Samba Server";
          after = [ "network.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
        };
        # Refer to https://github.com/samba-team/samba/tree/master/packaging/systemd
        # for correct use with systemd
        services = {
          samba-smbd = daemonService "smbd" "";
          samba-nmbd = mkIf cfg.enableNmbd (daemonService "nmbd" "");
          samba-winbindd = mkIf cfg.enableWinbindd (daemonService "winbindd" "");
        };
        tmpfiles.rules = [
          "d /var/lock/samba - - - - -"
          "d /var/log/samba - - - - -"
          "d /var/cache/samba - - - - -"
          "d /var/lib/samba/private - - - - -"
        ];
      };

      security.pam.services.samba = { };
      environment.systemPackages = [ cfg.package ];

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [
        139
        445
      ];
      networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [
        137
        138
      ];
    })
  ];

}
