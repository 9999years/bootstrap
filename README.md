# `bootstrap.ps1` is a script for “setting up” a Windows computer from scratch

In PowerShell:

    Set-ExecutionPolicy Bypass Process; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/9999years/bootstrap/master/bootstrap.ps1'))

Or from a “Run…” prompt:

    powershell -Command "Set-ExecutionPolicy Bypass Process; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/9999years/bootstrap/master/bootstrap.ps1'))"

`bootstrap.ps1` installs [Chocolatey], installs a bunch of applications I feel
are “critical” (or less-critical packages with the `-PackageLevel` option), and
then clones a bunch of Git repos:

1. My dotfiles (and symlinks them)
2. My Vim configuration (and its plugins)
3. My PowerShell files (and its modules)
4. My [AutoHotKey] scripts

It’s pretty tailored to my specific needs, but it’d be easy to customize it;
just modify the `bootstrap` function. Several helper functions are provided
that make adding additional components easy!

It’s important to me that this only be one file (because I expect to use this
on computers which don’t have git installed on) so the utility functions aren’t
factored out to a separate file for that reason.

## To-Do

* Set environment variables like `$PYTHONSTARTUP`. How do you even do that on
  Windows?

# `bootstrap.sh` is a script for “setting up” a Linux computer from scratch

    curl https://raw.githubusercontent.com/9999years/bootstrap/master/bootstrap.sh | bash

Yeah, you’re not supposed to do that, but I wrote the script and I’m the one
running it, so whatever. The Linux variant does a lot less than the PowerShell
variant, because

1. I frequently don’t have sudo on Linux boxes I’m working on
2. Linux comes with a lot more niceties by default than Windows
3. Compiling / installing software locally is so variable by the machine it’s
   not really worth trying to automate that much

The script clones a few Git repos:

1. My dotfiles (and symlinks them)
2. My Vim configuration (and its plugins)

[AutoHotKey]: https://autohotkey.com/
[Chocolatey]: https://chocolatey.org/
