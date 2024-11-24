{
  lib,
  stdenv,
  fetchFromGitLab,
  buildLinux,
  ...
}@args:

let
  # These names are how they are designated in https://xanmod.org.

  # NOTE: When updating these, please also take a look at the changes done to
  # kernel config in the xanmod version commit
  variants = {
    lts = {
      version = "6.6.63";
      hash = "sha256-P4B6r3p+Buu1Hf+RQsw5h2oUANVvQvQ4e/2gQcZ0vKw=";
    };

    main = {
      version = "6.11.10";
      hash = "sha256-WNzMM+P8c8Mv+FdrwcEPHwv/ppvgN2fiM+SHMmlAPYw=";
    };
  };

  xanmodKernelFor =
    {
      version,
      suffix ? "xanmod1",
      hash,
    }:
    buildLinux (
      args
      // rec {
        inherit version;
        modDirVersion = lib.versions.pad 3 "${version}-${suffix}";

        src = fetchFromGitLab {
          owner = "xanmod";
          repo = "linux";
          rev = modDirVersion;
          inherit hash;
        };

        structuredExtraConfig = with lib.kernel; {
          # CPUFreq governor Performance
          CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkOverride 60 yes;
          CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = lib.mkOverride 60 no;

          # Full preemption
          PREEMPT = lib.mkOverride 60 yes;
          PREEMPT_VOLUNTARY = lib.mkOverride 60 no;

          # Google's BBRv3 TCP congestion Control
          TCP_CONG_BBR = yes;
          DEFAULT_BBR = yes;

          # Preemptive Full Tickless Kernel at 250Hz
          HZ = freeform "250";
          HZ_250 = yes;
          HZ_1000 = no;

          # RCU_BOOST and RCU_EXP_KTHREAD
          RCU_EXPERT = yes;
          RCU_FANOUT = freeform "64";
          RCU_FANOUT_LEAF = freeform "16";
          RCU_BOOST = yes;
          RCU_BOOST_DELAY = freeform "0";
          RCU_EXP_KTHREAD = yes;
        };

        extraMeta = {
          branch = lib.versions.majorMinor version;
          maintainers = with lib.maintainers; [
            moni
            lovesegfault
            atemu
            shawn8901
            zzzsy
          ];
          description = "Built with custom settings and new features built to provide a stable, responsive and smooth desktop experience";
          broken = stdenv.isAarch64;
        };
      }
      // (args.argsOverride or { })
    );
in
{
  lts = xanmodKernelFor variants.lts;
  main = xanmodKernelFor variants.main;
}
