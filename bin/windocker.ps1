<#
   UserProfile
     |
     |-- dev-env
     |   |-- windocker (Windows docker environment scripts)
     |   |   |- bin
     |   |   \- lib
     |   |-- cygwin64 (Cygwin Installation)
     |   \-- downloads (downloaded setup executables)
     |       \-- cygwin (cygwin downloaded packages)
     |
     \-- my-docker
	 |-- uc4 (Home directory for UC4)
	 \-- intellij (Home directory for user's intellij)
#>
$DevEnvDir = "$env:UserProfile\dev-env"
$WindockerDir= "$DevEnvDir\windocker"
$DownloadDir = "$DevEnvDir\downloads"
$CygwinDir = "$DevEnvDir\cygwin64"
$CygwinPkgsDir = "$DownloadDir\cygwin"

$WindockerVersion=""
$WindockerURL="http://10.151.77.17:10080/windocker-$WindockerVersion.zip"

$GitDir = "C:\Program Files\Git"
$GitBash = "$GitDir\bin\bash"

$Shell = New-Object -ComObject("WScript.Shell")

function Unzip($zipfile, $outpath) {
  Start-Process "$GitDir/usr/bin/unzip.exe" `
    -ArgumentList "-u $zipfile -d $outpath"
}

function Download($uri, $outfile) {
  $webClient = New-Object System.Net.WebClient
  $Webclient.DownloadFile($uri, $outfile)
}

function Install-Windocker {
  $zip = "$DownloadDir\windocker-$WindockerVersion.zip"

  Download `
    -uri $WindockerURL `
    -outfile $zip

  Unzip $zip $DevEnvDir
}

function Create-WindockerSymlink {
  if (Test-Path "$WindockerDir") {
    Remove-Item -Recurse -Force "$WindockerDir"
  }
  Start-Process "$GitBash" `
    -ArgumentList "-c 'ln -sfT ""$DevEnvDir/windocker-$WindockerVersion"" ""$WindockerDir""'" `
    -Wait -NoNewWindow
}

function Create-Dir($path) {
  New-Item -ItemType Directory -Force -Path "$path"
}

function Create-Env {
  Create-Dir "$DevEnvDir"
  Create-Dir "$DownloadDir"
}

function Install-CygwinX {
  $setup = "$DownloadDir\setup-x86_64.exe"
  if (!(Test-Path "$setup")) {
    Download `
      -uri "https://cygwin.com/setup-x86_64.exe" `
      -outfile "$setup"
  }

  Start-Process "$setup" -ArgumentList "--site ""http://mirrors.xmission.com/cygwin"" --root ""$CygwinDir"" --packages xorg-server,xhost --no-admin --local-package-dir ""$CygwinPkgsDir"" --upgrade-also --quiet-mode" -Wait -NoNewWindow
}

function Install-DockerToolbox {
  $toolbox = "$DownloadDir\DockerToolbox.exe"

  if (!(Test-Path "$toolbox")) {
    Download `
      -uri "https://download.docker.com/win/stable/DockerToolbox.exe" `
      -outfile "$toolbox"
  }

  Start-Process "$toolbox" -ArgumentList "/SILENT" -Wait -NoNewWindow
}

function Create-DockerLink($name, $app, $ico) {
  $Shortcut = $Shell.CreateShortCut("$env:UserProfile\Desktop\$name.lnk")
  $Shortcut.TargetPath = $GitBash
  $Shortcut.Arguments="-login -i ""$WindockerDir\bin\start.sh"" $app"
  $Shortcut.iconLocation = $ico
  $Shortcut.save()
}

function Cygwin-X-Link {
  $Shortcut = $Shell.CreateShortCut("$env:UserProfile\Desktop\CygwinX.lnk")
  $Shortcut.TargetPath = "$CygwinDir\bin\sh.exe"
  $Shortcut.Arguments = "$WindockerDir\bin\cygwin-x.sh"
  $Shortcut.iconLocation = "$CygwinDir\Cygwin.ico"
  $Shortcut.save()
}

function UC4-Link {
  Create-DockerLink `
    -name UC4 `
    -app "$WindockerDir\bin\uc4" `
    -ico "$WindockerDir\lib\uc4.ico"
}

function Idea-Link {
  Create-DockerLink `
    -name Intellij `
    -app "$WindockerDir\bin\idea" `
    -ico "$WindockerDir\lib\idea.ico"
}

function DevShell-Link {
  Create-DockerLink `
    -name "Dev Shell" `
    -app "$WindockerDir\bin\devsh" `
    -ico "$WindockerDir\lib\idea.ico"
}

function Create-DockerMachine {
  Start-Process "$GitBash" `
    -ArgumentList "--login ""$WindockerDir\bin\windocker"" setup_docker_machine" `
    -Wait -NoNewWindow
}

function Setup-DeveloperEnv {
  Start-Process "$GitBash" `
    -ArgumentList "--login ""/c/Program Files/Docker Toolbox/start.sh"" ""$WindockerDir\bin\setup-devenv"" setup_developer_env" `
    -Wait -NoNewWindow
}

function Install($cygwinPath, $skipDockerToolbox) {
  Create-Env
  if ($PSBoundParameters.ContainsKey('cygwinPath')) {
    $CygwinDir = $cygwinPath
  } else {
    Install-CygwinX
  }
  if (!$PSBoundParameters.ContainsKey('skipDockerToolbox')) {
    Install-DockerToolbox
  }
  Install-Windocker
  Create-WindockerSymlink
  Create-DockerMachine
  Setup-DeveloperEnv
  Cygwin-X-Link
  UC4-Link
  Idea-Link
  DevShell-Link
}

Invoke-Expression "$args"
