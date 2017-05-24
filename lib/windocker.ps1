<#
   UserProfile
     |
     |-- dev-env
     |   |-- windocker (Windows docker environment scripts)
     |   |-- cygwin64 (Cygwin Installation)
     |   \-- downloads (downloaded setup executables)
     |       |
     |       |-- cygwin (cygwin downloaded packages)
     |
     \-- my-docker
	 |-- uc4 (Home directory for UC4)
	 \-- intellij (Home directory for user's intellij)
#>
$DevEnvDir = "$env:UserProfile\dev-env"
$MyDockerDir = "$env:UserProfile\my-docker"
$WindockerDir= "$DevEnvDir\windocker"
$DownloadDir = "$DevEnvDir\downloads"
$CygwinDir = "$DevEnvDir\cygwin64"
$CygwinPkgsDir = "$DownloadDir\cygwin"

$Shell = New-Object -ComObject("WScript.Shell")

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip($zipfile, $outpath) {
  [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function Download($uri, $outfile) {
  $webClient = New-Object System.Net.WebClient
  $Webclient.DownloadFile($uri, $outfile)
}

function Install-DevScripts {
  $zip = "$DownloadDir\windocker.zip"

  Download `
    -uri "" `
    -outfile $zip

  Unzip $zip $WindockerDir
}

function Create-Dir($path) {
  New-Item -ItemType Directory -Force -Path "$path"
}


function Create-Env {
  Create-Dir "$DevEnvDir"
  Create-Dir "$DownloadDir"
  Create-Dir "$MyDockerDir"

  Create-Dir "$MyDockerDir\uc4"
  Create-Dir "$MyDockerDir\intellij"
}


function Install-CygwinX {
  $setup = "$DownloadDir\setup-x86_64.exe"
  if (!(Test-Path "$setup")) {
    Download `
      -uri "https://cygwin.com/setup-x86_64.exe" `
      -outfile "$setup"
  }

  Start-Process "$setup" -ArgumentList "--site ""http://mirrors.xmission.com/cygwin"" --root ""$CygwinDir"" --packages xorg-server --no-admin --local-package-dir ""$CygwinPkgsDir"" --upgrade-also --quiet-mode" -Wait
}

function Install-DockerToolbox {
  $toolbox = "$DownloadDir\DockerToolbox.exe"

  if (!(Test-Path "$toolbox")) {
    Download `
      -uri "https://download.docker.com/win/stable/DockerToolbox.exe" `
      -outfile "$toolbox"
  }

  Start-Process "$toolbox" -ArgumentList "/SILENT" -Wait
}

function Cygwin-X-Link {
  $Shortcut = $Shell.CreateShortCut("$env:UserProfile\Desktop\CygwinX.lnk")
  $Shortcut.TargetPath = "$CygwinDir\bin\sh.exe"
  $Shortcut.Arguments="-c ""XWin :0 -listen tcp -multiwindow -clipboard"""
  $Shortcut.iconLocation = "$CygwinDir\Cygwin.ico"
  $Shortcut.save()
}

function UC4-Link {
  $Shortcut = $Shell.CreateShortCut("$env:UserProfile\Desktop\UC4.lnk")
  $Shortcut.TargetPath = "C:\Program Files\Git\bin\bash.exe"
  $Shortcut.Arguments="-login -i ""$WindockerDir\uc4"""
  $Shortcut.iconLocation = "$WinDockerDir\uc4.ico"
  $Shortcut.save()
}

function Intellij-Link {
  $Shortcut = $Shell.CreateShortCut("$env:UserProfile\Desktop\Intellij.lnk")
  $Shortcut.TargetPath = "C:\Program Files\Git\bin\bash.exe"
  $Shortcut.Arguments="-login -i ""$WindockerDir\intellij"""
  $Shortcut.iconLocation = "$WinDockerDir\idea.ico"
  $sHortcut.save()
}

function Create-DockerMachine {
  
}

function DoAll {
  Create-Env
  Install-CygwinX
  Install-DockerToolbox
  Create-DockerMachine
  Cygwin-X-Link
  UC4-Link
  Intellij-Link
}

$cmd=$args[0]

Invoke-Expression "$cmd"
