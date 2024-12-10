{
  lib,
  config,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.invidious;
  # To allow injecting secrets with jq, json (instead of yaml) is used
  settingsFormat = pkgs.formats.json { };
  inherit (lib) types;

  settingsFile = settingsFormat.generate "invidious-settings" cfg.settings;

  generatedHmacKeyFile = "/var/lib/invidious/hmac_key";
  generateHmac = cfg.hmacKeyFile == null;

  commonInvidousServiceConfig = {
    description = "Invidious (An alternative YouTube front-end)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ] ++ lib.optional cfg.database.createLocally "postgresql.service";
    requires = lib.optional cfg.database.createLocally "postgresql.service";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      RestartSec = "2s";
      DynamicUser = true;
      User = lib.mkIf (cfg.database.createLocally || cfg.serviceScale > 1) "invidious";
      StateDirectory = "invidious";
      StateDirectoryMode = "0750";

      CapabilityBoundingSet = "";
      PrivateDevices = true;
      PrivateUsers = true;
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];

      # Because of various issues Invidious must be restarted often, at least once a day, ideally
      # every hour.
      # This option enables the automatic restarting of the Invidious instance.
      # To ensure multiple instances of Invidious are not restarted at the exact same time, a
      # randomized extra offset of up to 5 minutes is added.
      Restart = lib.mkDefault "always";
      RuntimeMaxSec = lib.mkDefault "1h";
      RuntimeRandomizedExtraSec = lib.mkDefault "5min";
    };
  };
  mkInvidiousService =
    scaleIndex:
    lib.foldl' lib.recursiveUpdate commonInvidousServiceConfig [
      # only generate the hmac file in the first service
      (lib.optionalAttrs (scaleIndex == 0) {
        preStart = lib.optionalString generateHmac ''
          if [[ ! -e "${generatedHmacKeyFile}" ]]; then
            ${pkgs.pwgen}/bin/pwgen 20 1 > "${generatedHmacKeyFile}"
            chmod 0600 "${generatedHmacKeyFile}"
          fi
        '';
      })
      # configure the secondary services to run after the first service
      (lib.optionalAttrs (scaleIndex > 0) {
        after = commonInvidousServiceConfig.after ++ [ "invidious.service" ];
        wants = commonInvidousServiceConfig.wants ++ [ "invidious.service" ];
      })
      {
        script =
          ''
            configParts=()
          ''
          # autogenerated hmac_key
          + lib.optionalString generateHmac ''
            configParts+=("$(${pkgs.jq}/bin/jq -R '{"hmac_key":.}' <"${generatedHmacKeyFile}")")
          ''
          # generated settings file
          + ''
            configParts+=("$(< ${lib.escapeShellArg settingsFile})")
          ''
          # optional database password file
          + lib.optionalString (cfg.database.host != null) ''
            configParts+=("$(${pkgs.jq}/bin/jq -R '{"db":{"password":.}}' ${lib.escapeShellArg cfg.database.passwordFile})")
          ''
          # optional extra settings file
          + lib.optionalString (cfg.extraSettingsFile != null) ''
            configParts+=("$(< ${lib.escapeShellArg cfg.extraSettingsFile})")
          ''
          # explicitly specified hmac key file
          + lib.optionalString (cfg.hmacKeyFile != null) ''
            configParts+=("$(< ${lib.escapeShellArg cfg.hmacKeyFile})")
          ''
          # configure threads for secondary instances
          + lib.optionalString (scaleIndex > 0) ''
            configParts+=('{"channel_threads":0, "feed_threads":0}')
          ''
          # configure different ports for the instances
          + ''
            configParts+=('{"port":${toString (cfg.port + scaleIndex)}}')
          ''
          # merge all parts into a single configuration with later elements overriding previous elements
          + ''
            export INVIDIOUS_CONFIG="$(${pkgs.jq}/bin/jq -s 'reduce .[] as $item ({}; . * $item)' <<<"''${configParts[*]}")"
            exec ${cfg.package}/bin/invidious
          '';
      }
    ];

  serviceConfig = {
    systemd.services = builtins.listToAttrs (
      builtins.genList (scaleIndex: {
        name = "invidious" + lib.optionalString (scaleIndex > 0) "-${builtins.toString scaleIndex}";
        value = mkInvidiousService scaleIndex;
      }) cfg.serviceScale
    );

    services.invidious.settings =
      {
        # Automatically initialises and migrates the database if necessary
        check_tables = true;

        db = {
          user = lib.mkDefault (
            if (lib.versionAtLeast config.system.stateVersion "24.05") then "invidious" else "kemal"
          );
          dbname = lib.mkDefault "invidious";
          port = cfg.database.port;
          # Blank for unix sockets, see
          # https://github.com/will/crystal-pg/blob/1548bb255210/src/pq/conninfo.cr#L100-L108
          host = lib.optionalString (cfg.database.host != null) cfg.database.host;
          # Not needed because peer authentication is enabled
          password = lib.mkIf (cfg.database.host == null) "";
        };

        host_binding = cfg.address;
      }
      // (lib.optionalAttrs (cfg.domain != null) {
        inherit (cfg) domain;
      });

    assertions = [
      {
        assertion = cfg.database.host != null -> cfg.database.passwordFile != null;
        message = "If database host isn't null, database password needs to be set";
      }
      {
        assertion = cfg.serviceScale >= 1;
        message = "Service can't be scaled below one instance";
      }
    ];
  };

  # Settings necessary for running with an automatically managed local database
  localDatabaseConfig = lib.mkIf cfg.database.createLocally {
    assertions = [
      {
        assertion = cfg.settings.db.user == cfg.settings.db.dbname;
        message = ''
          For local automatic database provisioning (services.invidious.database.createLocally == true)
          to  work, the username used to connect to PostgreSQL must match the database name, that is
          services.invidious.settings.db.user must match services.invidious.settings.db.dbname.
          This is the default since NixOS 24.05. For older systems, it is normally safe to manually set
          the user to "invidious" as the new user will be created with permissions
          for the existing database. `REASSIGN OWNED BY kemal TO invidious;` may also be needed, it can be
          run as `sudo -u postgres env psql --user=postgres --dbname=invidious -c 'reassign OWNED BY kemal to invidious;'`.
        '';
      }
    ];
    # Default to using the local database if we create it
    services.invidious.database.host = lib.mkDefault null;

    services.postgresql = {
      enable = true;
      ensureUsers = lib.singleton {
        name = cfg.settings.db.user;
        ensureDBOwnership = true;
      };
      ensureDatabases = lib.singleton cfg.settings.db.dbname;
    };
  };

  ytproxyConfig = lib.mkIf cfg.http3-ytproxy.enable {
    systemd.services.http3-ytproxy = {
      description = "HTTP3 ytproxy for Invidious";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        mkdir -p socket
        exec ${lib.getExe cfg.http3-ytproxy.package};
      '';

      serviceConfig = {
        RestartSec = "2s";
        DynamicUser = true;
        User = lib.mkIf cfg.nginx.enable config.services.nginx.user;
        RuntimeDirectory = "http3-ytproxy";
        WorkingDirectory = "/run/http3-ytproxy";
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = lib.mkIf cfg.nginx.enable {
      locations."~ (^/videoplayback|^/vi/|^/ggpht/|^/sb/)" = {
        proxyPass = "http://unix:/run/http3-ytproxy/socket/http-proxy.sock";
      };
    };
  };

  sigHelperConfig = lib.mkIf cfg.sig-helper.enable {
    services.invidious.settings.signature_server = "tcp://${cfg.sig-helper.listenAddress}";
    systemd.services.invidious-sig-helper = {
      script = ''
        exec ${lib.getExe cfg.sig-helper.package} --tcp "${cfg.sig-helper.listenAddress}"
      '';
      wantedBy = [ "multi-user.target" ];
      before = [ "invidious.service" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = "invidious-sig-helper";
        DynamicUser = true;
        Restart = "always";

        PrivateTmp = true;
        PrivateUsers = true;
        ProtectSystem = true;
        ProtectProc = "invisible";
        ProtectHome = true;
        PrivateDevices = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        CapabilityBoundingSet = "";
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
          "@network-io"
        ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
      };
    };
  };

  nginxConfig = lib.mkIf cfg.nginx.enable {
    services.invidious.settings = {
      https_only = config.services.nginx.virtualHosts.${cfg.domain}.forceSSL;
      external_port = 80;
    };

    services.nginx =
      let
        ip = if cfg.address == "0.0.0.0" then "127.0.0.1" else cfg.address;
      in
      {
        enable = true;
        virtualHosts.${cfg.domain} = {
          locations."/".proxyPass =
            if cfg.serviceScale == 1 then "http://${ip}:${toString cfg.port}" else "http://upstream-invidious";

          enableACME = lib.mkDefault true;
          forceSSL = lib.mkDefault true;
        };
        upstreams = lib.mkIf (cfg.serviceScale > 1) {
          "upstream-invidious".servers = builtins.listToAttrs (
            builtins.genList (scaleIndex: {
              name = "${ip}:${toString (cfg.port + scaleIndex)}";
              value = { };
            }) cfg.serviceScale
          );
        };
      };

    assertions = [
      {
        assertion = cfg.domain != null;
        message = "To use services.invidious.nginx, you need to set services.invidious.domain";
      }
    ];
  };
in
{
  options.services.invidious = {
    enable = lib.mkEnableOption "Invidious";

    package = lib.mkPackageOption pkgs "invidious" { };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        The settings Invidious should use.

        See [config.example.yml](https://github.com/iv-org/invidious/blob/master/config/config.example.yml) for a list of all possible options.
      '';
    };

    hmacKeyFile = lib.mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        A path to a file containing the `hmac_key`. If `null`, a key will be generated automatically on first
        start.

        If non-`null`, this option overrides any `hmac_key` specified in {option}`services.invidious.settings` or
        via {option}`services.invidious.extraSettingsFile`.
      '';
    };

    extraSettingsFile = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        A file including Invidious settings.

        It gets merged with the settings specified in {option}`services.invidious.settings`
        and can be used to store secrets like `hmac_key` outside of the nix store.
      '';
    };

    serviceScale = lib.mkOption {
      type = types.int;
      default = 1;
      description = ''
        How many invidious instances to run.

        See https://docs.invidious.io/improve-public-instance/#2-multiple-invidious-processes for more details
        on how this is intended to work. All instances beyond the first one have the options `channel_threads`
        and `feed_threads` set to 0 to avoid conflicts with multiple instances refreshing subscriptions. Instances
        will be configured to bind to consecutive ports starting with {option}`services.invidious.port` for the
        first instance.
      '';
    };

    # This needs to be outside of settings to avoid infinite recursion
    # (determining if nginx should be enabled and therefore the settings
    # modified).
    domain = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The FQDN Invidious is reachable on.

        This is used to configure nginx and for building absolute URLs.
      '';
    };

    address = lib.mkOption {
      type = types.str;
      # default from https://github.com/iv-org/invidious/blob/master/config/config.example.yml
      default = if cfg.nginx.enable then "127.0.0.1" else "0.0.0.0";
      defaultText = lib.literalExpression ''if config.services.invidious.nginx.enable then "127.0.0.1" else "0.0.0.0"'';
      description = ''
        The IP address Invidious should bind to.
      '';
    };

    port = lib.mkOption {
      type = types.port;
      # Default from https://docs.invidious.io/Configuration.md
      default = 3000;
      description = ''
        The port Invidious should listen on.

        To allow access from outside,
        you can use either {option}`services.invidious.nginx`
        or add `config.services.invidious.port` to {option}`networking.firewall.allowedTCPPorts`.
      '';
    };

    database = {
      createLocally = lib.mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to create a local database with PostgreSQL.
        '';
      };

      host = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The database host Invidious should use.

          If `null`, the local unix socket is used. Otherwise
          TCP is used.
        '';
      };

      port = lib.mkOption {
        type = types.port;
        default = config.services.postgresql.settings.port;
        defaultText = lib.literalExpression "config.services.postgresql.settings.port";
        description = ''
          The port of the database Invidious should use.

          Defaults to the the default postgresql port.
        '';
      };

      passwordFile = lib.mkOption {
        type = types.nullOr types.str;
        apply = lib.mapNullable toString;
        default = null;
        description = ''
          Path to file containing the database password.
        '';
      };
    };

    nginx.enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to configure nginx as a reverse proxy for Invidious.

        It serves it under the domain specified in {option}`services.invidious.settings.domain` with enabled TLS and ACME.
        Further configuration can be done through {option}`services.nginx.virtualHosts.''${config.services.invidious.settings.domain}.*`,
        which can also be used to disable AMCE and TLS.
      '';
    };

    http3-ytproxy = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable http3-ytproxy for faster loading of images and video playback.

          If {option}`services.invidious.nginx.enable` is used, nginx will be configured automatically. If not, you
          need to configure a reverse proxy yourself according to
          https://docs.invidious.io/improve-public-instance/#3-speed-up-video-playback-with-http3-ytproxy.
        '';
      };

      package = lib.mkPackageOptionMD pkgs "http3-ytproxy" { };
    };

    sig-helper = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable and configure inv-sig-helper to emulate the youtube client's javascript. This is required
          to make certain videos playable.

          This will download and run completely untrusted javascript from youtube! While this service is sandboxed,
          this may still be an issue!
        '';
      };

      package = lib.mkPackageOption pkgs "inv-sig-helper" { };

      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:2999";
        description = ''
          The IP address/port where inv-sig-helper should listen.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      serviceConfig
      localDatabaseConfig
      nginxConfig
      ytproxyConfig
      sigHelperConfig
    ]
  );
}
