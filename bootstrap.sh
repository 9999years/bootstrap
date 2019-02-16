#! /bin/bash

GITHUB_USERNAME="9999years"

function maybe_clone {
	if [[ -z "$1" ]]
	then
		echo "Usage: maybe_clone REPO_NAME [DEST]"
		return 1
	fi
	if [[ ! -z "$2" ]]
	then
		DEST="$2"
	else
		DEST="$1"
	fi
	REPO="https://github.com/$GITHUB_USERNAME/$1"
	if [[ -e "$DEST" ]]
	then
		echo "$DEST already exists, not cloning..."
		return 1
	else
		git clone $REPO $DEST
	fi
}

cd $HOME
if maybe_clone dotfiles .dotfiles
then
	echo "Linking dotfiles ($HOME/dotfiles/setup.sh)"
	./.dotfiles/setup.sh
fi
if maybe_clone vimfiles .vim
then
	echo "Installing Vim plugins (vim +PlugInstall +qall!)"
	vim +PlugInstall +qall!
fi
