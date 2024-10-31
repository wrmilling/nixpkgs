{ config, lib, pkgs, ... }:
let

  name = "mpd";

  uid = config.ids.uids.mpd;
  gid = config.ids.gids.mpd;
  cfg = config.services.mpd;

  credentialsPlaceholder = (creds:
    let
      placeholders = (lib.imap0
        (i: c: ''password "{{password-${toString i}}}@${lib.concatStringsSep "," c.permissions}"'')
        creds);
    in
      lib.concatStringsSep "\n" placeholders);

  mpdConf = pkgs.writeText "mpd.conf" ''
    # This file was automatically generated by NixOS. Edit mpd's configuration
    # via NixOS' configuration.nix, as this file will be rewritten upon mpd's
    # restart.

    music_directory     "${cfg.musicDirectory}"
    playlist_directory  "${cfg.playlistDirectory}"
    ${lib.optionalString (cfg.dbFile != null) ''
      db_file             "${cfg.dbFile}"
    ''}
    state_file          "${cfg.dataDir}/state"
    sticker_file        "${cfg.dataDir}/sticker.sql"

    ${lib.optionalString (cfg.network.listenAddress != "any") ''bind_to_address "${cfg.network.listenAddress}"''}
    ${lib.optionalString (cfg.network.port != 6600)  ''port "${toString cfg.network.port}"''}
    ${lib.optionalString (cfg.fluidsynth) ''
      decoder {
              plugin "fluidsynth"
              soundfont "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2"
      }
    ''}

    ${lib.optionalString (cfg.credentials != []) (credentialsPlaceholder cfg.credentials)}

    ${cfg.extraConfig}
  '';

in {

  ###### interface

  options = {

    services.mpd = {

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable MPD, the music player daemon.
        '';
      };

      startWhenNeeded = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set, {command}`mpd` is socket-activated; that
          is, instead of having it permanently running as a daemon,
          systemd will start it on the first incoming connection.
        '';
      };

      musicDirectory = lib.mkOption {
        type = with lib.types; either path (strMatching "(http|https|nfs|smb)://.+");
        default = "${cfg.dataDir}/music";
        defaultText = lib.literalExpression ''"''${dataDir}/music"'';
        description = ''
          The directory or NFS/SMB network share where MPD reads music from. If left
          as the default value this directory will automatically be created before
          the MPD server starts, otherwise the sysadmin is responsible for ensuring
          the directory exists with appropriate ownership and permissions.
        '';
      };

      playlistDirectory = lib.mkOption {
        type = lib.types.path;
        default = "${cfg.dataDir}/playlists";
        defaultText = lib.literalExpression ''"''${dataDir}/playlists"'';
        description = ''
          The directory where MPD stores playlists. If left as the default value
          this directory will automatically be created before the MPD server starts,
          otherwise the sysadmin is responsible for ensuring the directory exists
          with appropriate ownership and permissions.
        '';
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Extra directives added to to the end of MPD's configuration file,
          mpd.conf. Basic configuration like file location and uid/gid
          is added automatically to the beginning of the file. For available
          options see {manpage}`mpd.conf(5)`.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/${name}";
        description = ''
          The directory where MPD stores its state, tag cache, playlists etc. If
          left as the default value this directory will automatically be created
          before the MPD server starts, otherwise the sysadmin is responsible for
          ensuring the directory exists with appropriate ownership and permissions.
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "User account under which MPD runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Group account under which MPD runs.";
      };

      network = {

        listenAddress = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          example = "any";
          description = ''
            The address for the daemon to listen on.
            Use `any` to listen on all addresses.
          '';
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 6600;
          description = ''
            This setting is the TCP port that is desired for the daemon to get assigned
            to.
          '';
        };

      };

      dbFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "${cfg.dataDir}/tag_cache";
        defaultText = lib.literalExpression ''"''${dataDir}/tag_cache"'';
        description = ''
          The path to MPD's database. If set to `null` the
          parameter is omitted from the configuration.
        '';
      };

      credentials = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            passwordFile = lib.mkOption {
              type = lib.types.path;
              description = ''
                Path to file containing the password.
              '';
            };
            permissions = let
              perms = ["read" "add" "control" "admin"];
            in lib.mkOption {
              type = lib.types.listOf (lib.types.enum perms);
              default = [ "read" ];
              description = ''
                List of permissions that are granted with this password.
                Permissions can be "${lib.concatStringsSep "\", \"" perms}".
              '';
            };
          };
        });
        description = ''
          Credentials and permissions for accessing the mpd server.
        '';
        default = [];
        example = [
          {passwordFile = "/var/lib/secrets/mpd_readonly_password"; permissions = [ "read" ];}
          {passwordFile = "/var/lib/secrets/mpd_admin_password"; permissions = ["read" "add" "control" "admin"];}
        ];
      };

      fluidsynth = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set, add fluidsynth soundfont and configure the plugin.
        '';
      };
    };

  };


  ###### implementation

  config = lib.mkIf cfg.enable {

    # install mpd units
    systemd.packages = [ pkgs.mpd ];

    systemd.sockets.mpd = lib.mkIf cfg.startWhenNeeded {
      wantedBy = [ "sockets.target" ];
      listenStreams = [
        ""  # Note: this is needed to override the upstream unit
        (if pkgs.lib.hasPrefix "/" cfg.network.listenAddress
          then cfg.network.listenAddress
          else "${lib.optionalString (cfg.network.listenAddress != "any") "${cfg.network.listenAddress}:"}${toString cfg.network.port}")
      ];
    };

    systemd.services.mpd = {
      wantedBy = lib.optional (!cfg.startWhenNeeded) "multi-user.target";

      preStart =
        ''
          set -euo pipefail
          install -m 600 ${mpdConf} /run/mpd/mpd.conf
        '' + lib.optionalString (cfg.credentials != [])
        (lib.concatStringsSep "\n"
          (lib.imap0
            (i: c: ''${pkgs.replace-secret}/bin/replace-secret '{{password-${toString i}}}' '${c.passwordFile}' /run/mpd/mpd.conf'')
            cfg.credentials));

      serviceConfig =
        {
          User = "${cfg.user}";
          # Note: the first "" overrides the ExecStart from the upstream unit
          ExecStart = [ "" "${pkgs.mpd}/bin/mpd --systemd /run/mpd/mpd.conf" ];
          RuntimeDirectory = "mpd";
          StateDirectory = []
            ++ lib.optionals (cfg.dataDir == "/var/lib/${name}") [ name ]
            ++ lib.optionals (cfg.playlistDirectory == "/var/lib/${name}/playlists") [ name "${name}/playlists" ]
            ++ lib.optionals (cfg.musicDirectory == "/var/lib/${name}/music")        [ name "${name}/music" ];
        };
    };

    users.users = lib.optionalAttrs (cfg.user == name) {
      ${name} = {
        inherit uid;
        group = cfg.group;
        extraGroups = [ "audio" ];
        description = "Music Player Daemon user";
        home = "${cfg.dataDir}";
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == name) {
      ${name}.gid = gid;
    };
  };

}
