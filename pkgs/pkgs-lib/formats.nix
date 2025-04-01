{ lib, pkgs }:
rec {

  /*
    Every following entry represents a format for program configuration files
    used for `settings`-style options (see https://github.com/NixOS/rfcs/pull/42).
    Each entry should look as follows:

      <format> = <parameters>: {
        #        ^^ Parameters for controlling the format

        # The module system type most suitable for representing such a format
        # The description needs to be overwritten for recursive types
        type = ...;

        # Utility functions for convenience, or special interactions with the
        # format (optional)
        lib = {
          exampleFunction = ...
          # Types specific to the format (optional)
          types = { ... };
          ...
        };

        # generate :: Name -> Value -> Path
        # A function for generating a file with a value of such a type
        generate = ...;

      });

    Please note that `pkgs` may not always be available for use due to the split
    options doc build introduced in fc614c37c653, so lazy evaluation of only the
    'type' field is required.
  */

  inherit (import ./formats/java-properties/default.nix { inherit lib pkgs; })
    javaProperties
    ;

  libconfig = (import ./formats/libconfig/default.nix { inherit lib pkgs; }).format;

  hocon = (import ./formats/hocon/default.nix { inherit lib pkgs; }).format;

  php = (import ./formats/php/default.nix { inherit lib pkgs; }).format;

  inherit (lib) mkOptionType;
  inherit (lib.types)
    nullOr
    oneOf
    coercedTo
    listOf
    nonEmptyListOf
    attrsOf
    either
    ;
  inherit (lib.types)
    bool
    int
    float
    str
    path
    ;

  json =
    { }:
    {

      type =
        let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "JSON value";
            };
        in
        valueType;

      generate =
        name: value:
        pkgs.callPackage (
          { runCommand, jq }:
          runCommand name
            {
              nativeBuildInputs = [ jq ];
              value = builtins.toJSON value;
              passAsFile = [ "value" ];
              preferLocalBuild = true;
            }
            ''
              jq . "$valuePath"> $out
            ''
        ) { };

    };

  yaml = yaml_1_1;

  yaml_1_1 =
    { }:
    {
      generate =
        name: value:
        pkgs.callPackage (
          { runCommand, remarshal_0_17 }:
          runCommand name
            {
              nativeBuildInputs = [ remarshal_0_17 ];
              value = builtins.toJSON value;
              passAsFile = [ "value" ];
              preferLocalBuild = true;
            }
            ''
              json2yaml "$valuePath" "$out"
            ''
        ) { };

      type =
        let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "YAML value";
            };
        in
        valueType;

    };

  # the ini formats share a lot of code
  inherit
    (
      let
        singleIniAtom =
          nullOr (oneOf [
            bool
            int
            float
            str
          ])
          // {
            description = "INI atom (null, bool, int, float or string)";
          };
        iniAtom =
          {
            listsAsDuplicateKeys,
            listToValue,
            atomsCoercedToLists,
          }:
          let
            singleIniAtomOr =
              if atomsCoercedToLists then coercedTo singleIniAtom lib.singleton else either singleIniAtom;
          in
          if listsAsDuplicateKeys then
            singleIniAtomOr (listOf singleIniAtom)
            // {
              description = singleIniAtom.description + " or a list of them for duplicate keys";
            }
          else if listToValue != null then
            singleIniAtomOr (nonEmptyListOf singleIniAtom)
            // {
              description = singleIniAtom.description + " or a non-empty list of them";
            }
          else
            singleIniAtom;
        iniSection =
          {
            listsAsDuplicateKeys,
            listToValue,
            atomsCoercedToLists,
          }@args:
          attrsOf (iniAtom args)
          // {
            description = "section of an INI file (attrs of " + (iniAtom args).description + ")";
          };

        maybeToList =
          listToValue:
          if listToValue != null then
            lib.mapAttrs (key: val: if lib.isList val then listToValue val else val)
          else
            lib.id;
      in
      {
        ini =
          {
            # Represents lists as duplicate keys
            listsAsDuplicateKeys ? false,
            # Alternative to listsAsDuplicateKeys, converts list to non-list
            # listToValue :: [IniAtom] -> IniAtom
            listToValue ? null,
            # Merge multiple instances of the same key into a list
            atomsCoercedToLists ? null,
            ...
          }@args:
          assert listsAsDuplicateKeys -> listToValue == null;
          assert atomsCoercedToLists != null -> (listsAsDuplicateKeys || listToValue != null);
          let
            atomsCoercedToLists' = if atomsCoercedToLists == null then false else atomsCoercedToLists;
          in
          {

            type = lib.types.attrsOf (iniSection {
              inherit listsAsDuplicateKeys listToValue;
              atomsCoercedToLists = atomsCoercedToLists';
            });

            generate =
              name: value:
              lib.pipe value [
                (lib.mapAttrs (_: maybeToList listToValue))
                (lib.generators.toINI (
                  removeAttrs args [
                    "listToValue"
                    "atomsCoercedToLists"
                  ]
                ))
                (pkgs.writeText name)
              ];
          };

        iniWithGlobalSection =
          {
            # Represents lists as duplicate keys
            listsAsDuplicateKeys ? false,
            # Alternative to listsAsDuplicateKeys, converts list to non-list
            # listToValue :: [IniAtom] -> IniAtom
            listToValue ? null,
            # Merge multiple instances of the same key into a list
            atomsCoercedToLists ? null,
            ...
          }@args:
          assert listsAsDuplicateKeys -> listToValue == null;
          assert atomsCoercedToLists != null -> (listsAsDuplicateKeys || listToValue != null);
          let
            atomsCoercedToLists' = if atomsCoercedToLists == null then false else atomsCoercedToLists;
          in
          {
            type = lib.types.submodule {
              options = {
                sections = lib.mkOption rec {
                  type = lib.types.attrsOf (iniSection {
                    inherit listsAsDuplicateKeys listToValue;
                    atomsCoercedToLists = atomsCoercedToLists';
                  });
                  default = { };
                  description = type.description;
                };
                globalSection = lib.mkOption rec {
                  type = iniSection {
                    inherit listsAsDuplicateKeys listToValue;
                    atomsCoercedToLists = atomsCoercedToLists';
                  };
                  default = { };
                  description = "global " + type.description;
                };
              };
            };
            generate =
              name:
              {
                sections ? { },
                globalSection ? { },
                ...
              }:
              pkgs.writeText name (
                lib.generators.toINIWithGlobalSection
                  (removeAttrs args [
                    "listToValue"
                    "atomsCoercedToLists"
                  ])
                  {
                    globalSection = maybeToList listToValue globalSection;
                    sections = lib.mapAttrs (_: maybeToList listToValue) sections;
                  }
              );
          };

        gitIni =
          {
            listsAsDuplicateKeys ? false,
            ...
          }@args:
          {
            type =
              let
                atom = iniAtom {
                  listsAsDuplicateKeys = listsAsDuplicateKeys;
                  listToValue = null;
                  atomsCoercedToLists = false;
                };
              in
              attrsOf (attrsOf (either atom (attrsOf atom)));

            generate = name: value: pkgs.writeText name (lib.generators.toGitINI value);
          };

      }
    )
    ini
    iniWithGlobalSection
    gitIni
    ;

  # As defined by systemd.syntax(7)
  #
  # null does not set any value, which allows for RFC42 modules to specify
  # optional config options.
  systemd =
    let
      mkValueString = lib.generators.mkValueStringDefault { };
      mkKeyValue = k: v: if v == null then "# ${k} is unset" else "${k} = ${mkValueString v}";
    in
    ini {
      listsAsDuplicateKeys = true;
      inherit mkKeyValue;
    };

  keyValue =
    {
      # Represents lists as duplicate keys
      listsAsDuplicateKeys ? false,
      # Alternative to listsAsDuplicateKeys, converts list to non-list
      # listToValue :: [Atom] -> Atom
      listToValue ? null,
      ...
    }@args:
    assert listsAsDuplicateKeys -> listToValue == null;
    {

      type =
        let

          singleAtom =
            nullOr (oneOf [
              bool
              int
              float
              str
            ])
            // {
              description = "atom (null, bool, int, float or string)";
            };

          atom =
            if listsAsDuplicateKeys then
              coercedTo singleAtom lib.singleton (listOf singleAtom)
              // {
                description = singleAtom.description + " or a list of them for duplicate keys";
              }
            else if listToValue != null then
              coercedTo singleAtom lib.singleton (nonEmptyListOf singleAtom)
              // {
                description = singleAtom.description + " or a non-empty list of them";
              }
            else
              singleAtom;

        in
        attrsOf atom;

      generate =
        name: value:
        let
          transformedValue =
            if listToValue != null then
              lib.mapAttrs (key: val: if lib.isList val then listToValue val else val) value
            else
              value;
        in
        pkgs.writeText name (
          lib.generators.toKeyValue (removeAttrs args [ "listToValue" ]) transformedValue
        );

    };

  toml =
    { }:
    json { }
    // {
      type =
        let
          valueType =
            oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ]
            // {
              description = "TOML value";
            };
        in
        valueType;

      generate =
        name: value:
        pkgs.callPackage (
          { runCommand, remarshal }:
          runCommand name
            {
              nativeBuildInputs = [ remarshal ];
              value = builtins.toJSON value;
              passAsFile = [ "value" ];
              preferLocalBuild = true;
            }
            ''
              json2toml "$valuePath" "$out"
            ''
        ) { };

    };

  /*
    For configurations of Elixir project, like config.exs or runtime.exs

    Most Elixir project are configured using the [Config] Elixir DSL

    Since Elixir has more types than Nix, we need a way to map Nix types to
    more than 1 Elixir type. To that end, this format provides its own library,
    and its own set of types.

    To be more detailed, a Nix attribute set could correspond in Elixir to a
    [Keyword list] (the more common type), or it could correspond to a [Map].

    A Nix string could correspond in Elixir to a [String] (also called
    "binary"), an [Atom], or a list of chars (usually discouraged).

    A Nix array could correspond in Elixir to a [List] or a [Tuple].

    Some more types exists, like records, regexes, but since they are less used,
    we can leave the `mkRaw` function as an escape hatch.

    For more information on how to use this format in modules, please refer to
    the Elixir section of the Nixos documentation.

    TODO: special Elixir values doesn't show up nicely in the documentation

    [Config]: <https://hexdocs.pm/elixir/Config.html>
    [Keyword list]: <https://hexdocs.pm/elixir/Keyword.html>
    [Map]: <https://hexdocs.pm/elixir/Map.html>
    [String]: <https://hexdocs.pm/elixir/String.html>
    [Atom]: <https://hexdocs.pm/elixir/Atom.html>
    [List]: <https://hexdocs.pm/elixir/List.html>
    [Tuple]: <https://hexdocs.pm/elixir/Tuple.html>
  */
  elixirConf =
    {
      elixir ? pkgs.elixir,
    }:
    let
      toElixir =
        value:
        if value == null then
          "nil"
        else if value == true then
          "true"
        else if value == false then
          "false"
        else if lib.isInt value || lib.isFloat value then
          toString value
        else if lib.isString value then
          string value
        else if lib.isAttrs value then
          attrs value
        else if lib.isList value then
          list value
        else
          abort "formats.elixirConf: should never happen (value = ${value})";

      escapeElixir = lib.escape [
        "\\"
        "#"
        "\""
      ];
      string = value: "\"${escapeElixir value}\"";

      attrs =
        set:
        if set ? _elixirType then
          specialType set
        else
          let
            toKeyword = name: value: "${name}: ${toElixir value}";
            keywordList = lib.concatStringsSep ", " (lib.mapAttrsToList toKeyword set);
          in
          "[" + keywordList + "]";

      listContent = values: lib.concatStringsSep ", " (map toElixir values);

      list = values: "[" + (listContent values) + "]";

      specialType =
        { value, _elixirType }:
        if _elixirType == "raw" then
          value
        else if _elixirType == "atom" then
          value
        else if _elixirType == "map" then
          elixirMap value
        else if _elixirType == "tuple" then
          tuple value
        else
          abort "formats.elixirConf: should never happen (_elixirType = ${_elixirType})";

      elixirMap =
        set:
        let
          toEntry = name: value: "${toElixir name} => ${toElixir value}";
          entries = lib.concatStringsSep ", " (lib.mapAttrsToList toEntry set);
        in
        "%{${entries}}";

      tuple = values: "{${listContent values}}";

      toConf =
        values:
        let
          keyConfig =
            rootKey: key: value:
            "config ${rootKey}, ${key}, ${toElixir value}";
          keyConfigs = rootKey: values: lib.mapAttrsToList (keyConfig rootKey) values;
          rootConfigs = lib.flatten (lib.mapAttrsToList keyConfigs values);
        in
        ''
          import Config

          ${lib.concatStringsSep "\n" rootConfigs}
        '';
    in
    {
      type =
        let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "Elixir value";
            };
        in
        attrsOf (attrsOf (valueType));

      lib =
        let
          mkRaw = value: {
            inherit value;
            _elixirType = "raw";
          };

        in
        {
          inherit mkRaw;

          # Fetch an environment variable at runtime, with optional fallback
          mkGetEnv =
            {
              envVariable,
              fallback ? null,
            }:
            mkRaw "System.get_env(${toElixir envVariable}, ${toElixir fallback})";

          /*
            Make an Elixir atom.

            Note: lowercase atoms still need to be prefixed by ':'
          */
          mkAtom = value: {
            inherit value;
            _elixirType = "atom";
          };

          # Make an Elixir tuple out of a list.
          mkTuple = value: {
            inherit value;
            _elixirType = "tuple";
          };

          # Make an Elixir map out of an attribute set.
          mkMap = value: {
            inherit value;
            _elixirType = "map";
          };

          /*
            Contains Elixir types. Every type it exports can also be replaced
            by raw Elixir code (i.e. every type is `either type rawElixir`).

            It also reexports standard types, wrapping them so that they can
            also be raw Elixir.
          */
          types =
            let
              isElixirType = type: x: (x._elixirType or "") == type;

              rawElixir = mkOptionType {
                name = "rawElixir";
                description = "raw elixir";
                check = isElixirType "raw";
              };

              elixirOr = other: either other rawElixir;
            in
            {
              inherit rawElixir elixirOr;

              atom = elixirOr (mkOptionType {
                name = "elixirAtom";
                description = "elixir atom";
                check = isElixirType "atom";
              });

              tuple = elixirOr (mkOptionType {
                name = "elixirTuple";
                description = "elixir tuple";
                check = isElixirType "tuple";
              });

              map = elixirOr (mkOptionType {
                name = "elixirMap";
                description = "elixir map";
                check = isElixirType "map";
              });
              # Wrap standard types, since anything in the Elixir configuration
              # can be raw Elixir
            }
            // lib.mapAttrs (_name: type: elixirOr type) lib.types;
        };

      generate =
        name: value:
        pkgs.runCommand name
          {
            value = toConf value;
            passAsFile = [ "value" ];
            nativeBuildInputs = [ elixir ];
            preferLocalBuild = true;
          }
          ''
            cp "$valuePath" "$out"
            mix format "$out"
          '';
    };

  # Outputs a succession of Python variable assignments
  # Useful for many Django-based services
  pythonVars =
    { }:
    {
      type =
        let
          valueType =
            nullOr (oneOf [
              bool
              float
              int
              path
              str
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "Python value";
            };
        in
        attrsOf valueType;
      generate =
        name: value:
        pkgs.callPackage (
          {
            runCommand,
            python3,
            black,
          }:
          runCommand name
            {
              nativeBuildInputs = [
                python3
                black
              ];
              value = builtins.toJSON value;
              pythonGen = ''
                import json
                import os

                with open(os.environ["valuePath"], "r") as f:
                    for key, value in json.load(f).items():
                        print(f"{key} = {repr(value)}")
              '';
              passAsFile = [
                "value"
                "pythonGen"
              ];
              preferLocalBuild = true;
            }
            ''
              cat "$valuePath"
              python3 "$pythonGenPath" > $out
              black $out
            ''
        ) { };
    };

}
