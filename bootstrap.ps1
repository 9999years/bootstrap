<#
.SYNOPSIS
Boostrapping script ; sets up entire workstation

.DESCRIPTION
Clones essential Git repositories, installs Chocolatey and related
packages.
If you'd like to install as a non-admin use -AllowNonAdmin; for speed,
you may prefer also adding -NonAdminChocolateyPackages ('git.portable',
'vim-tux.portable')

.PARAMATER AllowNonAdmin
Do not quit if not running as an administrator; NOTE that this does NOT
force a non-admin install if the command is running as an administrator

.LINK
https://github.com/9999years/bootstrap
#>
[CmdletBinding(SupportsShouldProcess = $True)]
Param (
	[Switch]$ForceChocolateyInstall,

	[ValidateSet("Tiny", "Normal", "Big", "Huge")]
	[String]$PackageLevel = "Normal",
	[Parameter(Mandatory=$False)]
	[String[]]$ChocolateyPackages
)

$packageLevels = (
	("Tiny", (
		"7zip.install",
		"autohotkey.install",
		"git-credential-manager-for-windows",
		"git.portable",
		"greenshot",
		"irfanview"
	)),

	("Normal", (
		"imagemagick.tool",
		"cccp",
		"discord.install",
		"irfanviewplugins",
		"pandoc",
		"steam",
		"sumatrapdf.install",
		"sysinternals",
		"telegram.install",
		"tixati",
		"vcredist140",
		"vcredist2010",
		"vcredist2013",
		"vcredist2015",
		"dotnet4.6.2"
	)),

	("Big", (
		"jetbrainstoolbox",
		"miktex.install",
		"mediamonkey",
		"swissfileknife"
	)),

	("Huge", (
		"visualstudio2017-installer",
		"visualstudio2017buildtools"
	))
)

# this is invoked at the end
function bootstrap {
	[CmdletBinding()]
	Param (
	)

	Begin {
		pushd
	}

	Process {
		$admin = Test-Administrator
		If(Get-Command choco) {
			important "Chocolatey appears to already be installed; to install anyways rerun with -ForceChocolateyInstall"
		} Else {
			important "Installing Chocolatey"
			If(!$admin) {
				If(!$AllowNonAdmin) {
					important "Running as non-admin; this seriously limits Chocolatey package choice"
					important "To continue, re-run this script with the -AllowNonAdmin option"
					return
				} Else {
					important "Installing as non-admin; some packages may fail"
					Install-Chocolatey -NonAdmin
				}
			} Else {
				Install-Chocolatey
			}
		}

		If($PSCmdlet.ShouldProcess("Install $ChocolateyPackages", "Install Chocolatey packages", "Install Chocolatey packages?")) {
			If(!$admin) {
				important "Installing non-admin Chocolatey packages and ignoring -ChocolateyPackages"
			} ElseIf($ChocolateyPackages) {
				important "Package level overriden with package list"
			} Else {
				important "Installing Chocolatey packages up to level $PackageLevel"
				$ChocolateyPackages = New-Object System.Collections.ArrayList
				ForEach($level in $packageLevels) {
					$name, $packs = $level
					$ChocolateyPackages.AddRange($packs)
					If($name -eq $PackageLevel) {
						Break
					}
				}
			}
			If($admin) {
				choco install $ChocolateyPackages
			} Else {
				choco install $NonAdminChocolateyPackages
			}
			If(!$?) {
				error "Chocolatey install failed; exiting"
				return
			}
		}

		refreshenv

		important "Enabling WSL (Windows Subsystem for Linux)"
		Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
		Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
	}

	End {
		popd
	}
}

# HELPER FUNCTIONS

<#
.SYNOPSIS
	Creates colored text using VT100 protocols; only available in PS after
	the Win10 anniversary update
.LINK
	https://docs.microsoft.com/en-us/powershell/wmf/5.1/console-improvements
.LINK
	https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
#>
function Get-ColoredText {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$True)]
		[String]$Text,
		[Int[]]$Escapes
	)

	Begin {
		$esc = [char]0x1b
		$reset = "${esc}[0m"
		$escaped = -join ($Escapes | %{ "${esc}[$($_)m" })
	}

	Process {
		return "$escaped$Text$reset"
	}
}

<#
.SYNOPSIS
	Writes text to the console in an important (bold) manner
#>
function important {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$True)]
		[String[]]$Text
	)

	Process {
		$Text | %{
			If ($Host.UI.SupportsVirtualTerminal) {
				Get-ColoredText ">>>> $_" (1, 92) # bold green
			} Else {
				"$_"
			}
		}
	}
}

<#
.SYNOPSIS
	Writes error text to the console
#>
function error {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$True)]
		[String[]]$Text
	)

	Process {
		$Text | %{
			If ($Host.UI.SupportsVirtualTerminal) {
				Get-ColoredText ">>>> $_" (1, 91) # bold red
			} Else {
				"$_"
			}
		}
	}
}

<#
.SYNOPSIS
	Clones a repository if it doesn't already exist; returns a boolean
	indicating if cloning happened successfully (i.e. indicating that the
	program can do things with files that are expected to be in the
	repository)
#>
function Maybe-Clone {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$True)]
		[String]$Repository,
		[String]$Message,
		[String]$Author = "9999years"
	)

	Process {
		Write-Verbose "Checking if $(Join-Path (pwd) $Repository) exists"
		If(Test-Path $Repository) {
			Write-Verbose "$Repository already exists; skipping"
			return $False
		} Else {
			Write-Verbose "$Repository doesn't exist; cloning"
			important $Message
			git clone "https://github.com/$Author/$Repository.git"
			$success = $?
			If(!$success) {
				error "Failed to clone $Repository"
			}
			return $success
		}
	}
}

<#
.SYNOPSIS
	returns True/False if the current user is an administrator
#>
function Test-Administrator {
	$user = New-Object Security.Principal.WindowsPrincipal] `
		([Security.Principal.WindowsIdentity]::GetCurrent())
	return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

<#
.SYNOPSIS
	Installs the Chocolatey package management system
.LINK
	https://chocolatey.org/
.LINK Non-administrative install
	https://chocolatey.org/docs/installation#non-administrative-install
.LINK Non-administrative choco packages
	https://chocolatey.org/packages?q=id%3Aportable
#>
function Install-Chocolatey {
	[CmdletBinding(SupportsShouldProcess = $True)]
	Param (
		[Switch]$NonAdmin
	)

	Process {
		If(!$PSCmdlet.ShouldProcess("Install Chocolatey?")) {
			return
		}
		If($NonAdmin) {
			$env:ChocolateyInstall = Path-Join $env:ProgramData "\chocoportable"
			important "Installing Chocolatey to ${env:ChocolateyInstall}"
			Set-ExecutionPolicy Bypass
		} Else {
			Set-ExecutionPolicy Bypass -Scope Process -Force
		}
		iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		# don't make us say 'yes' to every package
		choco feature enable --name allowGlobalConfirmation
	}
}

bootstrap
