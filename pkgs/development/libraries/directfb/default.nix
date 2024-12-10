{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  autoreconfHook,
  perl,
  pkg-config,
  flux,
  zlib,
  libjpeg,
  freetype,
  libpng,
  giflib,
  enableX11 ? true,
  xorg,
  enableSDL ? true,
  SDL,
}:

stdenv.mkDerivation rec {
  pname = "directfb";
  version = "1.7.7";

  src = fetchFromGitHub {
    owner = "deniskropp";
    repo = "DirectFB";
    rev = "DIRECTFB_${lib.replaceStrings [ "." ] [ "_" ] version}";
    sha256 = "0bs3yzb7hy3mgydrj8ycg7pllrd2b6j0gxj596inyr7ihssr3i0y";
  };

  patches = [
    # Fixes build in "davinci" with glibc >= 2.28
    # The "davinci" module is only enabled on 32-bit arm.
    # https://github.com/deniskropp/DirectFB/pull/17
    (fetchpatch {
      url = "https://github.com/deniskropp/DirectFB/commit/3a236241bbec3f15b012b6f0dbe94353d8094557.patch";
      sha256 = "0rj3gv0zlb225sqjz04p4yagy4xacf3210aa8vra8i1f0fv0w4kw";
    })

    # Fixes for build of `pkgsMusl.directfb`; applied everywhere to prevent patchrot
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/community/directfb/0001-directfb-fix-musl-compile.patch?id=f8158258493fc0c3eb5de2302e40f4bc44ecfb09";
      sha256 = "sha256-hmwzbaXu30ZkAqUn1NmvtlJkM6ctddKcO4hxh+1LSS4=";
    })
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/community/directfb/0002-Fix-musl-PTHREAD_RECURSIVE_MUTEX_INITIALIZER_NP-comp.patch?id=f8158258493fc0c3eb5de2302e40f4bc44ecfb09";
      sha256 = "sha256-j3+mcP6hV9LKuba1GOdcM1cZfmXuJtRgx4vE484jIns=";
    })
    # This uses POSIX basename() while directfb expects GNU
    # basename(), but the POSIX behaviour of modifying the input
    # should be fine since directfb never uses the buffer afterwards.
    (fetchpatch {
      url = "https://git.alpinelinux.org/aports/plain/community/directfb/fix-missing-basename.patch?id=bc049ae1bcf9ef3f66cd12a6fbb7ac4e917764b1";
      hash = "sha256-BX/C8+nh2fovHx8vKXFqKzBtfiTKUcW2BUCsaDIhodc=";
    })
  ];

  postPatch =
    ''
      # https://github.com/deniskropp/DirectFB/blob/master/src/core/Makefile.am#L15
      # BUILDTIME is embedded in the result
      # if switching to cmake then a similar substitution has to be done
      substituteInPlace src/core/Makefile.am \
        --replace '`date -u "+%Y-%m-%d %H:%M"`' "`date -u \"+%Y-%m-%d %H:%M\" --date="@''${SOURCE_DATE_EPOCH}"`"
    ''
    + lib.optionalString stdenv.hostPlatform.isMusl ''
      # Specifically patch out two drivers that have build errors with musl libc,
      # while leaving the rest of the default selection enabled
      substituteInPlace configure.in \
        --replace checkfor_lirc={yes,no} \
        --replace checkfor_matrox={yes,no}
    '';

  nativeBuildInputs = [
    autoreconfHook
    perl
    pkg-config
    flux
  ];

  buildInputs =
    [
      zlib
      libjpeg
      freetype
      giflib
      libpng
    ]
    ++ lib.optional enableSDL SDL
    ++ lib.optionals enableX11 (
      with xorg;
      [
        xorgproto
        libX11
        libXext
        libXrender
      ]
    );

  NIX_LDFLAGS = "-lgcc_s";

  configureFlags =
    [
      "--enable-sdl"
      "--enable-zlib"
      "--with-gfxdrivers=all"
      "--enable-devmem"
      "--enable-fbdev"
      "--enable-mmx"
      "--enable-sse"
      "--with-software"
    ]
    ++ lib.optional (!stdenv.hostPlatform.isMusl) "--with-smooth-scaling"
    ++ lib.optional enableX11 "--enable-x11";

  # Disable parallel building as parallel builds fail due to incomplete
  # depends between autogenerated CoreSlave.h and it's include sites:
  #    CC       prealloc_surface_pool_bridge.lo
  #    prealloc_surface_pool_bridge.c:41:10:
  #        fatal error: core/CoreSlave.h: No such file or directory
  #
  # Dependencies are specified manually in src/core/Makefile.am. Instead
  # of fixing them one by one locally let's disable parallel builds until
  # upstream fixes them.
  enableParallelBuilding = false;

  meta = with lib; {
    description = "Graphics and input library designed with embedded systems in mind";
    longDescription = ''
      DirectFB is a thin library that provides hardware graphics acceleration,
      input device handling and abstraction, integrated windowing system with
      support for translucent windows and multiple display layers, not only on
      top of the Linux Framebuffer Device. It is a complete hardware
      abstraction layer with software fallbacks for every graphics operation
      that is not supported by the underlying hardware. DirectFB adds graphical
      power to embedded systems and sets a new standard for graphics under
      Linux.
    '';
    homepage = "https://github.com/deniskropp/DirectFB";
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = [ maintainers.bjornfor ];
  };
}
