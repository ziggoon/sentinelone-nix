{
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  zlib,
  elfutils,
  dmidecode,
  jq,
  gcc-unwrapped,
}:
let
  sentinelOnePackage = "s1.deb";
in
stdenv.mkDerivation {
  pname = "sentinelone";
  version = "24.1.3.8";
  src = ./. + "/${sentinelOnePackage}";
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    zlib
    elfutils
    dmidecode
    jq
    gcc-unwrapped
  ];
  installPhase = ''
    mkdir -p $out/opt/
    mkdir -p $out/cfg/
    mkdir -p $out/bin/
    cp -r opt/* $out/opt
    ln -s $out/opt/sentinelone/bin/sentinelctl $out/bin/sentinelctl
    ln -s $out/opt/sentinelone/bin/sentinelone-agent $out/bin/sentinelone-agent
    ln -s $out/opt/sentinelone/bin/sentinelone-watchdog $out/bin/sentinelone-watchdog
    ln -s $out/opt/sentinelone/lib $out/lib
  '';
  preFixup = ''
    patchelf --replace-needed libelf.so.0 libelf.so $out/opt/sentinelone/lib/libbpf.so
  '';
}
