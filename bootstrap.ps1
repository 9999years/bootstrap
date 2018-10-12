<#
.SYNOPSIS
	Boostrapping script ; sets up entire workstation
.DESCRIPTION
	Clones essential Git repositories, installs Chocolatey and related
	packages.

	If you'd like to install as a non-admin use -AllowNonAdmin; for speed,
	you may prefer also adding -NonAdminChocolateyPackages ('git.portable',
	'vim-tux.portable')

.PARAM AllowNonAdmin
	Do not quit if not running as an administrator; NOTE that this does NOT
	force a non-admin install if the command is running as an administrator
.LINK
	https://github.com/9999years/bootstrap
#>
[CmdletBinding()]
Param (
	[String[]]$ChocolateyPackages = (
		"7zip.install",
		"ag",
		"autohotkey.install",
		"ConEmu",
		"curl",
		"Cygwin",
		"diffutils",
		"git-credential-manager-for-windows",
		"git.portable",
		"greenshot",
		"hub",
		"irfanview",
		"jetbrainstoolbox",
		"python",
		"putty.install",
		"sumatrapdf.install",
		"sysinternals",
		"vim-tux.install",
		"wget",
		"winscp.portable"
	),
	[Switch]$AllowNonAdmin
	[String[]]$NonAdminChocolateyPackages = (
		"7zip.portable",
		"ag",
		"autohotkey.portable",
		"ConEmu",
		"curl",
		"Cygwin",
		"diffutils",
		"git.portable",
		"greenshot",
		"hub",
		"irfanview",
		"jetbrainstoolbox", # ...?
		"python",
		"putty.portable",
		"sysinternals",
		"vim-tux.portable",
		"winscp.portable"
	),
)

# this is invoked at the end
function bootstrap {
	important "Installing Chocolatey"
	$admin = Test-Administrator
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

	important "Installing important Chocolatey packages"
	choco install $ChocolateyPackages

	refreshenv

	pushd

	cd ~
	If(Maybe-Clone dotfiles "Setting up dotfiles (./dotfiles/setup.ps1)") {
		./dotfiles/setup.ps1 -Overwrite Force
	}

	If(Maybe-Clone vimfiles "Setting up Vim") {
		important "Installing Vim plugins (vim +PlugInstall +qall!)"
		vim +PlugInstall +qall!
	}

	cd ~/Documents
	Maybe-Clone 9999years/ahk "Downloading AHK scripts"
	If(Maybe-Clone 9999years/WindowsPowerShell "Downloading PowerShell config") {
		important "Setting up PowerShell environment (./WindowsPowerShell/setup.ps1)"
		./WindowsPowerShell/setup.ps1
	}

	"Other choco packages to consider (choco install ...):
	`tbfg-repo-cleaner cccp cloc discord.install Ghostscript.app
	gnuwin32-make.portable GoogleChrome graphviz hugo irfanviewplugins jdk8
	jre8 maven meld miktex.install pandoc pdftk ruby rust soulseek steam
	strawberryperl telegram.install tixati visualstudio2017buildtools"

	popd
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
	}

	Process {
		return "$(-join ($Escapes | %{
			"${esc}[$($_)m"
		}))$Text$reset"
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
				Get-ColoredText ">>>> $_" (1, 92)
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
				Get-ColoredText ">>>> $_" (1, 91)
			} Else {
				"$_"
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
		If(Test-Directory $Repository) {
			return $False
		} Else {
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
	[Security.Principal.WindowsPrincipal]::New(
		[Security.Principal.WindowsIdentity]::GetCurrent()
	).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
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
	[CmdletBinding()]
	Param (
		[Switch]$NonAdmin
	)

	If($NonAdmin) {
		$InstallDir = Path-Join $env:ProgramData "\chocoportable"
		$env:ChocolateyInstall = "$InstallDir"
		Set-ExecutionPolicy Bypass
	} Else {
		Set-ExecutionPolicy Bypass -Scope Process -Force
	}
	iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	# don't make us say 'yes' to every package
	choco feature enable --name allowGlobalConfirmation
}

bootstrap
