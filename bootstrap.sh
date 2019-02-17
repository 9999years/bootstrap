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
	pushd
	cd .dotfiles
	if not which abs2rel
	then
		echo "Downloading 'abs2rel' locally"
		curl "https://raw.githubusercontent.com/9999years/abs2rel/master/abs2rel.py" \
			-O ./abs2rel
		chmod +x ./abs2rel
	fi
	echo "Linking dotfiles ($HOME/dotfiles/setup.sh)"
	./setup.sh
	rm -f ./abs2rel
	popd
fi
if maybe_clone vimfiles .vim
then
	echo "Installing Vim plugins (vim +PlugInstall +qall!)"
	vim +PlugInstall +qall!
fi
