{ lib, appimageTools, fetchurl, stdenv }:

let
  version = "4.1.3";
  pname = "oxwu";
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://eew.earthquake.tw/releases/linux/x64/oxwu-linux-x86_64.AppImage";
      hash = "sha256-MtcWrQpro+IBYWMxV6gdI6YsRkygtNKR0h7h97WHO8M="; # x86_64
    };
    aarch64-linux = fetchurl {
      url = "https://eew.earthquake.tw/releases/linux/arm64/oxwu-linux-arm64.AppImage";
      hash = "sha256-MPJavJvhWu8D3vokGwMeaXQnxeXn2cMx6uvTGqAwwX0="; # aarch64
    };
    armv7l-linux = fetchurl {
      url = "https://eew.earthquake.tw/releases/linux/armv7l/oxwu-linux-armv7l.AppImage";
      hash = "sha256-5MQ2S+rt90mwVNARTEc8i72Uze6jfmxOEpqNfbswiNU="; # armv7l
    };
  };
  src = srcs.${stdenv.hostPlatform.system};
  extracted = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    install -Dm644 ${extracted}/oxwu.desktop $out/share/applications/oxwu.desktop
    substituteInPlace $out/share/applications/oxwu.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=oxwu --ozone-platform-hint=auto %U'
    install -Dm644 ${extracted}/usr/share/icons/hicolor/512x512/apps/oxwu.png \
      $out/share/icons/hicolor/512x512/apps/oxwu.png
  '';
  meta = with lib; {
    description = "地牛Wake Up! 台灣地震速報";
    homepage = "https://eew.earthquake.tw";
    license = licenses.unfree;
    platforms = builtins.attrNames srcs;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
