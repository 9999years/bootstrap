# `bootstrap.ps1` is a script for “setting up” a computer from scratch

bootstrap.ps1 installs [Chocolatey], installs a bunch of applications I feel are “critical”, and then clones a bunch of Git repos:

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

[AutoHotKey]: https://autohotkey.com/
[Chocolatey]: https://chocolatey.org/
