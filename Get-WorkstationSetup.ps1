# Setup my execution policy for both the 64 bit and 32 bit shells
set-executionpolicy remotesigned
start-job -runas32 {set-executionpolicy remotesigned} | receive-job -wait

# Install the latest stable ChefDK
invoke-restmethod 'https://omnitruck.chef.io/install.ps1' | iex
install-project chefdk -verbose

# Install Chocolatey
invoke-expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

# Get a basic setup recipe
invoke-restmethod 'https://gist.githubusercontent.com/rrxtns/96b339d6218d611b139762b9eb56983c/raw/2987d7c8301b60f1b16b5348caffa48778182751/simple-workstation.rb' | out-file -encoding ascii -filepath c:/simple-workstation.rb

# Use Chef Apply to setup 
chef-apply c:/simple-workstation.rb

# Swiped from: https://knowledge.zomers.eu/PowerShell/Pages/How-to-configure-Windows-Explorer-settings-via-PowerShell.aspx
$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
Set-ItemProperty $key ShowSuperHidden 0
Stop-Process -processname explorer

# Setup our PowerShell Profile - create the directory for it if it doesn't already exist
[string]$filePath = $profile;
if(!(Test-Path $filePath)) {
  New-Item -Force ([System.IO.Path]::GetDirectoryName($filePath)) | Out-Null;
};

# Place Get-Buffer.ps1 so we can output awesome looking code
invoke-restmethod 'https://raw.githubusercontent.com/rrxtns/Set-PowerShellProfile/master/Get-Buffer.ps1' | out-file -encoding ascii -filepath C:/Users/$env:UserName/Documents/Get-Buffer.ps1
# Now place the PowerShell profile
invoke-restmethod 'https://raw.githubusercontent.com/rrxtns/Set-PowerShellProfile/master/Set-PowerShellProfile.ps1' | out-file -encoding ascii -filepath C:/Users/$env:UserName/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1
# Now lets update the Path
$env:Path += ";C:\Users\$env:UserName\Documents\"

# Finally, reload the profile
. $profile