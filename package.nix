{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
}:
let
  sources = lib.importJSON ./sources.json;
  pname = "orca-ide";
  inherit (sources) version;
  asset =
    sources.assets.${stdenv.hostPlatform.system}
      or (throw "orca-ide: unsupported system ${stdenv.hostPlatform.system}");

  src = fetchurl {
    inherit (asset) url hash;
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/orca-ide.desktop \
      $out/share/applications/orca-ide.desktop
    substituteInPlace $out/share/applications/orca-ide.desktop \
      --replace-fail 'Exec=AppRun %U' 'Exec=orca-ide %U'
    cp -r ${appimageContents}/usr/share/icons $out/share/icons
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Agent development environment for running coding agents in parallel";
    homepage = "https://www.onorca.dev/";
    downloadPage = "https://github.com/stablyai/orca/releases";
    license = lib.licenses.mit;
    mainProgram = "orca-ide";
    platforms = builtins.attrNames sources.assets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
