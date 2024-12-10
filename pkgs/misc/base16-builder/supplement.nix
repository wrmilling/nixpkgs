# This file has been generated by node2nix 1.11.1. Do not edit!

{
  nodeEnv,
  fetchurl,
  fetchgit,
  nix-gitignore,
  stdenv,
  lib,
  globalBuildInputs ? [ ],
}:

let
  sources = {
    "abbrev-1.1.1" = {
      name = "abbrev";
      packageName = "abbrev";
      version = "1.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/abbrev/-/abbrev-1.1.1.tgz";
        sha512 = "nne9/IiQ/hzIhY6pdDnbBtz7DjPTKrY00P/zvPSm5pOFkl6xuGrGnXn/VtTNNfNtAfZ9/1RtehkszU9qcTii0Q==";
      };
    };
    "ansi-regex-2.1.1" = {
      name = "ansi-regex";
      packageName = "ansi-regex";
      version = "2.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/ansi-regex/-/ansi-regex-2.1.1.tgz";
        sha512 = "TIGnTpdo+E3+pCyAluZvtED5p5wCqLdezCyhPZzKPcxvFplEt4i+W7OONCKgeZFT3+y5NZZfOOS/Bdcanm1MYA==";
      };
    };
    "aproba-1.2.0" = {
      name = "aproba";
      packageName = "aproba";
      version = "1.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/aproba/-/aproba-1.2.0.tgz";
        sha512 = "Y9J6ZjXtoYh8RnXVCMOU/ttDmk1aBjunq9vO0ta5x85WDQiQfUF9sIPBITdbiiIVcBo03Hi3jMxigBtsddlXRw==";
      };
    };
    "are-we-there-yet-1.1.7" = {
      name = "are-we-there-yet";
      packageName = "are-we-there-yet";
      version = "1.1.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/are-we-there-yet/-/are-we-there-yet-1.1.7.tgz";
        sha512 = "nxwy40TuMiUGqMyRHgCSWZ9FM4VAoRP4xUYSTv5ImRog+h9yISPbVH7H8fASCIzYn9wlEv4zvFL7uKDMCFQm3g==";
      };
    };
    "balanced-match-1.0.2" = {
      name = "balanced-match";
      packageName = "balanced-match";
      version = "1.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/balanced-match/-/balanced-match-1.0.2.tgz";
        sha512 = "3oSeUO0TMV67hN1AmbXsK4yaqU7tjiHlbxRDZOpH0KW9+CeX4bRAaX0Anxt0tx2MrpRpWwQaPwIlISEJhYU5Pw==";
      };
    };
    "brace-expansion-1.1.11" = {
      name = "brace-expansion";
      packageName = "brace-expansion";
      version = "1.1.11";
      src = fetchurl {
        url = "https://registry.npmjs.org/brace-expansion/-/brace-expansion-1.1.11.tgz";
        sha512 = "iCuPHDFgrHX7H2vEI/5xpz07zSHB00TpugqhmYtVmMO6518mCuRMoOYFldEBl0g187ufozdaHgWKcYFb61qGiA==";
      };
    };
    "chownr-1.1.4" = {
      name = "chownr";
      packageName = "chownr";
      version = "1.1.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/chownr/-/chownr-1.1.4.tgz";
        sha512 = "jJ0bqzaylmJtVnNgzTeSOs8DPavpbYgEr/b0YL8/2GO3xJEhInFmhKMUnEJQjZumK7KXGFhUy89PrsJWlakBVg==";
      };
    };
    "code-point-at-1.1.0" = {
      name = "code-point-at";
      packageName = "code-point-at";
      version = "1.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/code-point-at/-/code-point-at-1.1.0.tgz";
        sha512 = "RpAVKQA5T63xEj6/giIbUEtZwJ4UFIc3ZtvEkiaUERylqe8xb5IvqcgOurZLahv93CLKfxcw5YI+DZcUBRyLXA==";
      };
    };
    "concat-map-0.0.1" = {
      name = "concat-map";
      packageName = "concat-map";
      version = "0.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/concat-map/-/concat-map-0.0.1.tgz";
        sha512 = "/Srv4dswyQNBfohGpz9o6Yb3Gz3SrUDqBH5rTuhGR7ahtlbYKnVxw2bCFMRljaA7EXHaXZ8wsHdodFvbkhKmqg==";
      };
    };
    "console-control-strings-1.1.0" = {
      name = "console-control-strings";
      packageName = "console-control-strings";
      version = "1.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/console-control-strings/-/console-control-strings-1.1.0.tgz";
        sha512 = "ty/fTekppD2fIwRvnZAVdeOiGd1c7YXEixbgJTNzqcxJWKQnjJ/V1bNEEE6hygpM3WjwHFUVK6HTjWSzV4a8sQ==";
      };
    };
    "core-util-is-1.0.3" = {
      name = "core-util-is";
      packageName = "core-util-is";
      version = "1.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/core-util-is/-/core-util-is-1.0.3.tgz";
        sha512 = "ZQBvi1DcpJ4GDqanjucZ2Hj3wEO5pZDS89BWbkcrvdxksJorwUDDZamX9ldFkp9aw2lmBDLgkObEA4DWNJ9FYQ==";
      };
    };
    "debug-3.2.7" = {
      name = "debug";
      packageName = "debug";
      version = "3.2.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/debug/-/debug-3.2.7.tgz";
        sha512 = "CFjzYYAi4ThfiQvizrFQevTTXHtnCqWfe7x1AhgEscTz6ZbLbfoLRLPugTQyBth6f8ZERVUSyWHFD/7Wu4t1XQ==";
      };
    };
    "deep-extend-0.6.0" = {
      name = "deep-extend";
      packageName = "deep-extend";
      version = "0.6.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/deep-extend/-/deep-extend-0.6.0.tgz";
        sha512 = "LOHxIOaPYdHlJRtCQfDIVZtfw/ufM8+rVj649RIHzcm/vGwQRXFt6OPqIFWsm2XEMrNIEtWR64sY1LEKD2vAOA==";
      };
    };
    "delegates-1.0.0" = {
      name = "delegates";
      packageName = "delegates";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/delegates/-/delegates-1.0.0.tgz";
        sha512 = "bd2L678uiWATM6m5Z1VzNCErI3jiGzt6HGY8OVICs40JQq/HALfbyNJmp0UDakEY4pMMaN0Ly5om/B1VI/+xfQ==";
      };
    };
    "detect-libc-1.0.3" = {
      name = "detect-libc";
      packageName = "detect-libc";
      version = "1.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/detect-libc/-/detect-libc-1.0.3.tgz";
        sha512 = "pGjwhsmsp4kL2RTz08wcOlGN83otlqHeD/Z5T8GXZB+/YcpQ/dgo+lbU8ZsGxV0HIvqqxo9l7mqYwyYMD9bKDg==";
      };
    };
    "fs-minipass-1.2.7" = {
      name = "fs-minipass";
      packageName = "fs-minipass";
      version = "1.2.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/fs-minipass/-/fs-minipass-1.2.7.tgz";
        sha512 = "GWSSJGFy4e9GUeCcbIkED+bgAoFyj7XF1mV8rma3QW4NIqX9Kyx79N/PF61H5udOV3aY1IaMLs6pGbH71nlCTA==";
      };
    };
    "fs.realpath-1.0.0" = {
      name = "fs.realpath";
      packageName = "fs.realpath";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/fs.realpath/-/fs.realpath-1.0.0.tgz";
        sha512 = "OO0pH2lK6a0hZnAdau5ItzHPI6pUlvI7jMVnxUQRtw4owF2wk8lOSabtGDCTP4Ggrg2MbGnWO9X8K1t4+fGMDw==";
      };
    };
    "gauge-2.7.4" = {
      name = "gauge";
      packageName = "gauge";
      version = "2.7.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/gauge/-/gauge-2.7.4.tgz";
        sha512 = "14x4kjc6lkD3ltw589k0NrPD6cCNTD6CWoVUNpB85+DrtONoZn+Rug6xZU5RvSC4+TZPxA5AnBibQYAvZn41Hg==";
      };
    };
    "glob-7.2.3" = {
      name = "glob";
      packageName = "glob";
      version = "7.2.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/glob/-/glob-7.2.3.tgz";
        sha512 = "nFR0zLpU2YCaRxwoCJvL6UvCH2JFyFVIvwTLsIf21AuHlMskA1hhTdk+LlYJtOlYt9v6dvszD2BGRqBL+iQK9Q==";
      };
    };
    "has-unicode-2.0.1" = {
      name = "has-unicode";
      packageName = "has-unicode";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/has-unicode/-/has-unicode-2.0.1.tgz";
        sha512 = "8Rf9Y83NBReMnx0gFzA8JImQACstCYWUplepDa9xprwwtmgEZUF0h/i5xSA625zB/I37EtrswSST6OXxwaaIJQ==";
      };
    };
    "iconv-lite-0.4.24" = {
      name = "iconv-lite";
      packageName = "iconv-lite";
      version = "0.4.24";
      src = fetchurl {
        url = "https://registry.npmjs.org/iconv-lite/-/iconv-lite-0.4.24.tgz";
        sha512 = "v3MXnZAcvnywkTUEZomIActle7RXXeedOR31wwl7VlyoXO4Qi9arvSenNQWne1TcRwhCL1HwLI21bEqdpj8/rA==";
      };
    };
    "ignore-walk-3.0.4" = {
      name = "ignore-walk";
      packageName = "ignore-walk";
      version = "3.0.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/ignore-walk/-/ignore-walk-3.0.4.tgz";
        sha512 = "PY6Ii8o1jMRA1z4F2hRkH/xN59ox43DavKvD3oDpfurRlOJyAHpifIwpbdv1n4jt4ov0jSpw3kQ4GhJnpBL6WQ==";
      };
    };
    "inflight-1.0.6" = {
      name = "inflight";
      packageName = "inflight";
      version = "1.0.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/inflight/-/inflight-1.0.6.tgz";
        sha512 = "k92I/b08q4wvFscXCLvqfsHCrjrF7yiXsQuIVvVE7N82W3+aqpzuUdBbfhWcy/FZR3/4IgflMgKLOsvPDrGCJA==";
      };
    };
    "inherits-2.0.4" = {
      name = "inherits";
      packageName = "inherits";
      version = "2.0.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/inherits/-/inherits-2.0.4.tgz";
        sha512 = "k/vGaX4/Yla3WzyMCvTQOXYeIHvqOKtnqBduzTHpzpQZzAskKMhZ2K+EnBiSM9zGSoIFeMpXKxa4dYeZIQqewQ==";
      };
    };
    "ini-1.3.8" = {
      name = "ini";
      packageName = "ini";
      version = "1.3.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/ini/-/ini-1.3.8.tgz";
        sha512 = "JV/yugV2uzW5iMRSiZAyDtQd+nxtUnjeLt0acNdw98kKLrvuRVyB80tsREOE7yvGVgalhZ6RNXCmEHkUKBKxew==";
      };
    };
    "is-fullwidth-code-point-1.0.0" = {
      name = "is-fullwidth-code-point";
      packageName = "is-fullwidth-code-point";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/is-fullwidth-code-point/-/is-fullwidth-code-point-1.0.0.tgz";
        sha512 = "1pqUqRjkhPJ9miNq9SwMfdvi6lBJcd6eFxvfaivQhaH3SgisfiuudvFntdKOmxuee/77l+FPjKrQjWvmPjWrRw==";
      };
    };
    "isarray-1.0.0" = {
      name = "isarray";
      packageName = "isarray";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/isarray/-/isarray-1.0.0.tgz";
        sha512 = "VLghIWNM6ELQzo7zwmcg0NmTVyWKYjvIeM83yjp0wRDTmUnrM678fQbcKBo6n2CJEF0szoG//ytg+TKla89ALQ==";
      };
    };
    "minimatch-3.1.2" = {
      name = "minimatch";
      packageName = "minimatch";
      version = "3.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/minimatch/-/minimatch-3.1.2.tgz";
        sha512 = "J7p63hRiAjw1NDEww1W7i37+ByIrOWO5XQQAzZ3VOcL0PNybwpfmV/N05zFAzwQ9USyEcX6t3UO+K5aqBQOIHw==";
      };
    };
    "minimist-1.2.8" = {
      name = "minimist";
      packageName = "minimist";
      version = "1.2.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/minimist/-/minimist-1.2.8.tgz";
        sha512 = "2yyAR8qBkN3YuheJanUpWC5U3bb5osDywNB8RzDVlDwDHbocAJveqqj1u8+SVD7jkWT4yvsHCpWqqWqAxb0zCA==";
      };
    };
    "minipass-2.9.0" = {
      name = "minipass";
      packageName = "minipass";
      version = "2.9.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/minipass/-/minipass-2.9.0.tgz";
        sha512 = "wxfUjg9WebH+CUDX/CdbRlh5SmfZiy/hpkxaRI16Y9W56Pa75sWgd/rvFilSgrauD9NyFymP/+JFV3KwzIsJeg==";
      };
    };
    "minizlib-1.3.3" = {
      name = "minizlib";
      packageName = "minizlib";
      version = "1.3.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/minizlib/-/minizlib-1.3.3.tgz";
        sha512 = "6ZYMOEnmVsdCeTJVE0W9ZD+pVnE8h9Hma/iOwwRDsdQoePpoX56/8B6z3P9VNwppJuBKNRuFDRNRqRWexT9G9Q==";
      };
    };
    "mkdirp-0.5.6" = {
      name = "mkdirp";
      packageName = "mkdirp";
      version = "0.5.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/mkdirp/-/mkdirp-0.5.6.tgz";
        sha512 = "FP+p8RB8OWpF3YZBCrP5gtADmtXApB5AMLn+vdyA+PyxCjrCs00mjyUozssO33cwDeT3wNGdLxJ5M//YqtHAJw==";
      };
    };
    "ms-2.1.3" = {
      name = "ms";
      packageName = "ms";
      version = "2.1.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/ms/-/ms-2.1.3.tgz";
        sha512 = "6FlzubTLZG3J2a/NVCAleEhjzq5oxgHyaCU9yYXvcLsvoVaHJq/s5xXI6/XXP6tz7R9xAOtHnSO/tXtF3WRTlA==";
      };
    };
    "needle-2.9.1" = {
      name = "needle";
      packageName = "needle";
      version = "2.9.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/needle/-/needle-2.9.1.tgz";
        sha512 = "6R9fqJ5Zcmf+uYaFgdIHmLwNldn5HbK8L5ybn7Uz+ylX/rnOsSp1AHcvQSrCaFN+qNM1wpymHqD7mVasEOlHGQ==";
      };
    };
    "nopt-4.0.3" = {
      name = "nopt";
      packageName = "nopt";
      version = "4.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/nopt/-/nopt-4.0.3.tgz";
        sha512 = "CvaGwVMztSMJLOeXPrez7fyfObdZqNUK1cPAEzLHrTybIua9pMdmmPR5YwtfNftIOMv3DPUhFaxsZMNTQO20Kg==";
      };
    };
    "npm-bundled-1.1.2" = {
      name = "npm-bundled";
      packageName = "npm-bundled";
      version = "1.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/npm-bundled/-/npm-bundled-1.1.2.tgz";
        sha512 = "x5DHup0SuyQcmL3s7Rx/YQ8sbw/Hzg0rj48eN0dV7hf5cmQq5PXIeioroH3raV1QC1yh3uTYuMThvEQF3iKgGQ==";
      };
    };
    "npm-normalize-package-bin-1.0.1" = {
      name = "npm-normalize-package-bin";
      packageName = "npm-normalize-package-bin";
      version = "1.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/npm-normalize-package-bin/-/npm-normalize-package-bin-1.0.1.tgz";
        sha512 = "EPfafl6JL5/rU+ot6P3gRSCpPDW5VmIzX959Ob1+ySFUuuYHWHekXpwdUZcKP5C+DS4GEtdJluwBjnsNDl+fSA==";
      };
    };
    "npm-packlist-1.4.8" = {
      name = "npm-packlist";
      packageName = "npm-packlist";
      version = "1.4.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/npm-packlist/-/npm-packlist-1.4.8.tgz";
        sha512 = "5+AZgwru5IevF5ZdnFglB5wNlHG1AOOuw28WhUq8/8emhBmLv6jX5by4WJCh7lW0uSYZYS6DXqIsyZVIXRZU9A==";
      };
    };
    "npmlog-4.1.2" = {
      name = "npmlog";
      packageName = "npmlog";
      version = "4.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/npmlog/-/npmlog-4.1.2.tgz";
        sha512 = "2uUqazuKlTaSI/dC8AzicUck7+IrEaOnN/e0jd3Xtt1KcGpwx30v50mL7oPyr/h9bL3E4aZccVwpwP+5W9Vjkg==";
      };
    };
    "number-is-nan-1.0.1" = {
      name = "number-is-nan";
      packageName = "number-is-nan";
      version = "1.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/number-is-nan/-/number-is-nan-1.0.1.tgz";
        sha512 = "4jbtZXNAsfZbAHiiqjLPBiCl16dES1zI4Hpzzxw61Tk+loF+sBDBKx1ICKKKwIqQ7M0mFn1TmkN7euSncWgHiQ==";
      };
    };
    "object-assign-4.1.1" = {
      name = "object-assign";
      packageName = "object-assign";
      version = "4.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/object-assign/-/object-assign-4.1.1.tgz";
        sha512 = "rJgTQnkUnH1sFw8yT6VSU3zD3sWmu6sZhIseY8VX+GRu3P6F7Fu+JNDoXfklElbLJSnc3FUQHVe4cU5hj+BcUg==";
      };
    };
    "once-1.4.0" = {
      name = "once";
      packageName = "once";
      version = "1.4.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/once/-/once-1.4.0.tgz";
        sha512 = "lNaJgI+2Q5URQBkccEKHTQOPaXdUxnZZElQTZY0MFUAuaEqe1E+Nyvgdz/aIyNi6Z9MzO5dv1H8n58/GELp3+w==";
      };
    };
    "os-homedir-1.0.2" = {
      name = "os-homedir";
      packageName = "os-homedir";
      version = "1.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/os-homedir/-/os-homedir-1.0.2.tgz";
        sha512 = "B5JU3cabzk8c67mRRd3ECmROafjYMXbuzlwtqdM8IbS8ktlTix8aFGb2bAGKrSRIlnfKwovGUUr72JUPyOb6kQ==";
      };
    };
    "os-tmpdir-1.0.2" = {
      name = "os-tmpdir";
      packageName = "os-tmpdir";
      version = "1.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/os-tmpdir/-/os-tmpdir-1.0.2.tgz";
        sha512 = "D2FR03Vir7FIu45XBY20mTb+/ZSWB00sjU9jdQXt83gDrI4Ztz5Fs7/yy74g2N5SVQY4xY1qDr4rNddwYRVX0g==";
      };
    };
    "osenv-0.1.5" = {
      name = "osenv";
      packageName = "osenv";
      version = "0.1.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/osenv/-/osenv-0.1.5.tgz";
        sha512 = "0CWcCECdMVc2Rw3U5w9ZjqX6ga6ubk1xDVKxtBQPK7wis/0F2r9T6k4ydGYhecl7YUBxBVxhL5oisPsNxAPe2g==";
      };
    };
    "path-is-absolute-1.0.1" = {
      name = "path-is-absolute";
      packageName = "path-is-absolute";
      version = "1.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/path-is-absolute/-/path-is-absolute-1.0.1.tgz";
        sha512 = "AVbw3UJ2e9bq64vSaS9Am0fje1Pa8pbGqTTsmXfaIiMpnr5DlDhfJOuLj9Sf95ZPVDAUerDfEk88MPmPe7UCQg==";
      };
    };
    "process-nextick-args-2.0.1" = {
      name = "process-nextick-args";
      packageName = "process-nextick-args";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/process-nextick-args/-/process-nextick-args-2.0.1.tgz";
        sha512 = "3ouUOpQhtgrbOa17J7+uxOTpITYWaGP7/AhoR3+A+/1e9skrzelGi/dXzEYyvbxubEF6Wn2ypscTKiKJFFn1ag==";
      };
    };
    "rc-1.2.8" = {
      name = "rc";
      packageName = "rc";
      version = "1.2.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/rc/-/rc-1.2.8.tgz";
        sha512 = "y3bGgqKj3QBdxLbLkomlohkvsA8gdAiUQlSBJnBhfn+BPxg4bc62d8TcBW15wavDfgexCgccckhcZvywyQYPOw==";
      };
    };
    "readable-stream-2.3.8" = {
      name = "readable-stream";
      packageName = "readable-stream";
      version = "2.3.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/readable-stream/-/readable-stream-2.3.8.tgz";
        sha512 = "8p0AUk4XODgIewSi0l8Epjs+EVnWiK7NoDIEGU0HhE7+ZyY8D1IMY7odu5lRrFXGg71L15KG8QrPmum45RTtdA==";
      };
    };
    "rimraf-2.7.1" = {
      name = "rimraf";
      packageName = "rimraf";
      version = "2.7.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/rimraf/-/rimraf-2.7.1.tgz";
        sha512 = "uWjbaKIK3T1OSVptzX7Nl6PvQ3qAGtKEtVRjRuazjfL3Bx5eI409VZSqgND+4UNnmzLVdPj9FqFJNPqBZFve4w==";
      };
    };
    "safe-buffer-5.1.2" = {
      name = "safe-buffer";
      packageName = "safe-buffer";
      version = "5.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.1.2.tgz";
        sha512 = "Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==";
      };
    };
    "safe-buffer-5.2.1" = {
      name = "safe-buffer";
      packageName = "safe-buffer";
      version = "5.2.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.2.1.tgz";
        sha512 = "rp3So07KcdmmKbGvgaNxQSJr7bGVSVk5S9Eq1F+ppbRo70+YeaDxkw5Dd8NPN+GD6bjnYm2VuPuCXmpuYvmCXQ==";
      };
    };
    "safer-buffer-2.1.2" = {
      name = "safer-buffer";
      packageName = "safer-buffer";
      version = "2.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/safer-buffer/-/safer-buffer-2.1.2.tgz";
        sha512 = "YZo3K82SD7Riyi0E1EQPojLz7kpepnSQI9IyPbHHg1XXXevb5dJI7tpyN2ADxGcQbHG7vcyRHk0cbwqcQriUtg==";
      };
    };
    "sax-1.2.4" = {
      name = "sax";
      packageName = "sax";
      version = "1.2.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/sax/-/sax-1.2.4.tgz";
        sha512 = "NqVDv9TpANUjFm0N8uM5GxL36UgKi9/atZw+x7YFnQ8ckwFGKrl4xX4yWtrey3UJm5nP1kUbnYgLopqWNSRhWw==";
      };
    };
    "semver-5.7.1" = {
      name = "semver";
      packageName = "semver";
      version = "5.7.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/semver/-/semver-5.7.1.tgz";
        sha512 = "sauaDf/PZdVgrLTNYHRtpXa1iRiKcaebiKQ1BJdpQlWH2lCvexQdX55snPFyK7QzpudqbCI0qXFfOasHdyNDGQ==";
      };
    };
    "set-blocking-2.0.0" = {
      name = "set-blocking";
      packageName = "set-blocking";
      version = "2.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/set-blocking/-/set-blocking-2.0.0.tgz";
        sha512 = "KiKBS8AnWGEyLzofFfmvKwpdPzqiy16LvQfK3yv/fVH7Bj13/wl3JSR1J+rfgRE9q7xUJK4qvgS8raSOeLUehw==";
      };
    };
    "signal-exit-3.0.7" = {
      name = "signal-exit";
      packageName = "signal-exit";
      version = "3.0.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/signal-exit/-/signal-exit-3.0.7.tgz";
        sha512 = "wnD2ZE+l+SPC/uoS0vXeE9L1+0wuaMqKlfz9AMUo38JsyLSBWSFcHR1Rri62LZc12vLr1gb3jl7iwQhgwpAbGQ==";
      };
    };
    "string-width-1.0.2" = {
      name = "string-width";
      packageName = "string-width";
      version = "1.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/string-width/-/string-width-1.0.2.tgz";
        sha512 = "0XsVpQLnVCXHJfyEs8tC0zpTVIr5PKKsQtkT29IwupnPTjtPmQ3xT/4yCREF9hYkV/3M3kzcUTSAZT6a6h81tw==";
      };
    };
    "string_decoder-1.1.1" = {
      name = "string_decoder";
      packageName = "string_decoder";
      version = "1.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/string_decoder/-/string_decoder-1.1.1.tgz";
        sha512 = "n/ShnvDi6FHbbVfviro+WojiFzv+s8MPMHBczVePfUpDJLwoLT0ht1l4YwBCbi8pJAveEEdnkHyPyTP/mzRfwg==";
      };
    };
    "strip-ansi-3.0.1" = {
      name = "strip-ansi";
      packageName = "strip-ansi";
      version = "3.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/strip-ansi/-/strip-ansi-3.0.1.tgz";
        sha512 = "VhumSSbBqDTP8p2ZLKj40UjBCV4+v8bUSEpUb4KjRgWk9pbqGF4REFj6KEagidb2f/M6AzC0EmFyDNGaw9OCzg==";
      };
    };
    "strip-json-comments-2.0.1" = {
      name = "strip-json-comments";
      packageName = "strip-json-comments";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/strip-json-comments/-/strip-json-comments-2.0.1.tgz";
        sha512 = "4gB8na07fecVVkOI6Rs4e7T6NOTki5EmL7TUduTs6bu3EdnSycntVJ4re8kgZA+wx9IueI2Y11bfbgwtzuE0KQ==";
      };
    };
    "tar-4.4.19" = {
      name = "tar";
      packageName = "tar";
      version = "4.4.19";
      src = fetchurl {
        url = "https://registry.npmjs.org/tar/-/tar-4.4.19.tgz";
        sha512 = "a20gEsvHnWe0ygBY8JbxoM4w3SJdhc7ZAuxkLqh+nvNQN2IOt0B5lLgM490X5Hl8FF0dl0tOf2ewFYAlIFgzVA==";
      };
    };
    "util-deprecate-1.0.2" = {
      name = "util-deprecate";
      packageName = "util-deprecate";
      version = "1.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/util-deprecate/-/util-deprecate-1.0.2.tgz";
        sha512 = "EPD5q1uXyFxJpCrLnCc1nHnq3gOa6DZBocAIiI2TaSCA7VCJ1UJDMagCzIkXNsUYfD1daK//LTEQ8xiIbrHtcw==";
      };
    };
    "wide-align-1.1.5" = {
      name = "wide-align";
      packageName = "wide-align";
      version = "1.1.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/wide-align/-/wide-align-1.1.5.tgz";
        sha512 = "eDMORYaPNZ4sQIuuYPDHdQvf4gyCF9rEEV/yPxGfwPkRodwEgiMUUXTx/dex+Me0wxx53S+NgUHaP7y3MGlDmg==";
      };
    };
    "wrappy-1.0.2" = {
      name = "wrappy";
      packageName = "wrappy";
      version = "1.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/wrappy/-/wrappy-1.0.2.tgz";
        sha512 = "l4Sp/DRseor9wL6EvV2+TuQn63dMkPjZ/sp9XkghTEbV9KlPS1xUsZ3u7/IQO4wxtcFB4bgpQPRcR3QCvezPcQ==";
      };
    };
    "yallist-3.1.1" = {
      name = "yallist";
      packageName = "yallist";
      version = "3.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/yallist/-/yallist-3.1.1.tgz";
        sha512 = "a4UGQaWPH59mOXUYnAG2ewncQS4i4F43Tv3JoAM+s2VDAmS9NsK8GpDMLrCHPksFT7h3K6TOoUNn2pb7RoXx4g==";
      };
    };
  };
in
{
  node-pre-gyp = nodeEnv.buildNodePackage {
    name = "node-pre-gyp";
    packageName = "node-pre-gyp";
    version = "0.17.0";
    src = fetchurl {
      url = "https://registry.npmjs.org/node-pre-gyp/-/node-pre-gyp-0.17.0.tgz";
      sha512 = "abzZt1hmOjkZez29ppg+5gGqdPLUuJeAEwVPtHYEJgx0qzttCbcKFpxrCQn2HYbwCv2c+7JwH4BgEzFkUGpn4A==";
    };
    dependencies = [
      sources."abbrev-1.1.1"
      sources."ansi-regex-2.1.1"
      sources."aproba-1.2.0"
      sources."are-we-there-yet-1.1.7"
      sources."balanced-match-1.0.2"
      sources."brace-expansion-1.1.11"
      sources."chownr-1.1.4"
      sources."code-point-at-1.1.0"
      sources."concat-map-0.0.1"
      sources."console-control-strings-1.1.0"
      sources."core-util-is-1.0.3"
      sources."debug-3.2.7"
      sources."deep-extend-0.6.0"
      sources."delegates-1.0.0"
      sources."detect-libc-1.0.3"
      sources."fs-minipass-1.2.7"
      sources."fs.realpath-1.0.0"
      sources."gauge-2.7.4"
      sources."glob-7.2.3"
      sources."has-unicode-2.0.1"
      sources."iconv-lite-0.4.24"
      sources."ignore-walk-3.0.4"
      sources."inflight-1.0.6"
      sources."inherits-2.0.4"
      sources."ini-1.3.8"
      sources."is-fullwidth-code-point-1.0.0"
      sources."isarray-1.0.0"
      sources."minimatch-3.1.2"
      sources."minimist-1.2.8"
      sources."minipass-2.9.0"
      sources."minizlib-1.3.3"
      sources."mkdirp-0.5.6"
      sources."ms-2.1.3"
      sources."needle-2.9.1"
      sources."nopt-4.0.3"
      sources."npm-bundled-1.1.2"
      sources."npm-normalize-package-bin-1.0.1"
      sources."npm-packlist-1.4.8"
      sources."npmlog-4.1.2"
      sources."number-is-nan-1.0.1"
      sources."object-assign-4.1.1"
      sources."once-1.4.0"
      sources."os-homedir-1.0.2"
      sources."os-tmpdir-1.0.2"
      sources."osenv-0.1.5"
      sources."path-is-absolute-1.0.1"
      sources."process-nextick-args-2.0.1"
      sources."rc-1.2.8"
      sources."readable-stream-2.3.8"
      sources."rimraf-2.7.1"
      sources."safe-buffer-5.1.2"
      sources."safer-buffer-2.1.2"
      sources."sax-1.2.4"
      sources."semver-5.7.1"
      sources."set-blocking-2.0.0"
      sources."signal-exit-3.0.7"
      sources."string-width-1.0.2"
      sources."string_decoder-1.1.1"
      sources."strip-ansi-3.0.1"
      sources."strip-json-comments-2.0.1"
      (
        sources."tar-4.4.19"
        // {
          dependencies = [
            sources."safe-buffer-5.2.1"
          ];
        }
      )
      sources."util-deprecate-1.0.2"
      sources."wide-align-1.1.5"
      sources."wrappy-1.0.2"
      sources."yallist-3.1.1"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "Node.js native addon binary install tool";
      homepage = "https://github.com/mapbox/node-pre-gyp#readme";
      license = "BSD-3-Clause";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
