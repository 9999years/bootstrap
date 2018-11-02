# `bootstrap.ps1` is a script for “setting up” a computer from scratch

    Set-ExecutionPolicy Bypass Process; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/9999years/bootstrap/master/bootstrap.ps1'))

Or...

    powershell -Command "Set-ExecutionPolicy Bypass Process; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/9999years/bootstrap/master/bootstrap.ps1'))"

bootstrap.ps1 installs [Chocolatey], installs a bunch of applications I feel
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

[AutoHotKey]: https://autohotkey.com/
[Chocolatey]: https://chocolatey.org/
