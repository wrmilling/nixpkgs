{
  godot3,
  mono,
  scons,
  python311Packages,
}:

(godot3.override {
  scons = scons.override {
    python3Packages = python311Packages;
  };
}).overrideAttrs
  (
    self: base: {
      pname = "godot3-mono-glue";
      godotBuildDescription = "mono glue";
      godotBuildPlatform = "server";

      sconsFlags = base.sconsFlags ++ [
        "module_mono_enabled=true"
        "mono_glue=false" # Indicates not to expect already existing glue.
        "mono_prefix=${mono}"
      ];

      nativeBuildInputs = base.nativeBuildInputs ++ [ mono ];

      patches =
        base.patches
        ++ map (rp: ./patches + rp) ([
          # When building godot mono, a "glue version" gets baked into it, and into the mono glue code
          # generated by it. Godot mono export templates are also get a glue version baked in. If you
          # export a godot mono project using an export template for which the glue version doesn't
          # match that of the godot mono tool itself, then the resulting game will fail with an error
          # saying "The assembly 'GodotSharp' is out of sync." Thus, if we want our build of godot mono
          # to be compatible with the official export templates, we need to ensure it is built with the
          # same glue version as the official build.
          #
          # A python script in the godot source, i.e. modules/mono/build_scripts/gen_cs_glue_version.py,
          # is used by the build process to generate the glue version number. The official version of it
          # does so based on the latest modified time of all the C# files in the GodotSharp solution. This
          # is problematic because it is difficult to reproduce the exact timestamps that the files had
          # when the official build was created. This is further complicated by the fact that nix clears
          # the timestamps on the source files when they're unpacked. Thus, we can't simply regenerate the
          # official glue version by building from the official source.
          #
          # To address this, we are patching the python script with a hard-coded glue version number. This
          # patch file needs to be updated for every new version of godot, so to enforce this, the godot
          # version is baked in to the file name, causing the build to fail until the patch is updated.
          #
          # The correct glue version number for a given godot version is obtained by running the official
          # build of that version of godot with the --generate-mono-glue flag. This generates the mono
          # glue files.  One of those files, mono_glue.gen.cpp, has a function called get_cs_glue_version()
          # which contains a hard-coded number.  This is the glue version to put in the patch file.
          #
          # For convenience, the accompanying update-glue-version.sh script automates this work. Run it by
          # passing the godot version as an argument, e.g. "3.5.2".
          "/gen_cs_glue_version.py/hardcodeGlueVersion_${self.version}.patch"
        ]);

      outputs = [ "out" ];

      installPhase = ''
        runHook preInstall

        glue="$out"/modules/mono/glue
        mkdir -p "$glue"
        bin/godot_server.x11.opt.tools.*.mono --generate-mono-glue "$glue"

        runHook postInstall
      '';

      meta = base.meta // {
        homepage = "https://docs.godotengine.org/en/stable/development/compiling/compiling_with_mono.html#generate-the-glue";
      };
    }
  )
