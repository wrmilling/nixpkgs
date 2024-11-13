{ lib, buildDotnetGlobalTool }:
buildDotnetGlobalTool {
  pname = "upgrade-assistant";
  version = "0.5.820";

  nugetHash = "sha256-GB+q5aZRkBTeXUbIPjkPsll6pSI/H6Iyh5mY53uT284=";

  meta = {
    homepage = "https://github.com/dotnet/upgrade-assistant";
    description = "Tool to assist developers in upgrading .NET Framework applications to .NET 6 and beyond";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ khaneliman ];
    mainProgram = "ugprade-assistant";
    platforms = lib.platforms.all;
  };
}
