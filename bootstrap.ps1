<#
.SYNOPSIS
	Boostrapping script ; sets up entire workstation
.DESCRIPTION
	Clones essential Git repositories, installs Chocolatey and related
	packages
.LINK
	https://github.com/9999years/bootstrap
#>
[CmdletBinding()]
Param (
)

<#
.SYNOPSIS
	Writes colored text using VT100 protocols...
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
	indicating if cloning happened successfully
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
			hub clone "$Author/$Repository"
			$success = $?
			If(!$success) {
				error "Failed to clone $Repository"
			}
			return $success
		}
	}
}

important "Installing Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

important "Installing important Chocolatey packages"
choco install (
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
	)

refreshenv

pushd

cd ~
If(Maybe-Clone dotfiles "Setting up dotfiles") {
	./dotfiles/setup.ps1 -Overwrite Force
}

If(Maybe-Clone vimfiles "Setting up Vim") {
	important "Installing Vim plugins"
	vim +PlugInstall +qall!
}

cd ~/Documents
Maybe-Clone 9999years/ahk "Downloading AHK scripts"
If(Maybe-Clone 9999years/WindowsPowerShell "Downloading PowerShell config") {
	important "Setting up PowerShell environment"
	./WindowsPowerShell/setup.ps1
}

"Other chocolatey packages to consider:"
"`tbfg-repo-cleaner cccp cloc discord.install Ghostscript.app gnuwin32-make.portable GoogleChrome graphviz hugo irfanviewplugins jdk8 jre8 maven meld miktex.install pandoc pdftk ruby rust soulseek steam strawberryperl telegram.install tixati visualstudio2017buildtools"

popd
