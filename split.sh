#!/usr/bin/env sh
#
# run this from root folder
PATH_MONOREPO=`pwd`

usage() {
    echo "----"
    echo "WARNING: this is work in progress use at your own risks"
    echo "What does it do ?"
    echo "  it git subtree split some folders into local branches"
    echo "  merge thoses changes to another git local repository"
    echo "  push thoses changes to remote"
    echo " "
    echo "just call $0 from root folder of your repository"
    echo ""
}

#split / merge / push process
split() {
    local dest=$1
    local subtree=$2
    local branch=$3
    local repo=$4

    echo "----"
    echo "split $subtee to branch $branch"
    echo ""
    git subtree split -P $subtree -b $branch

    echo "----"
    echo "cd to $dest"
    echo ""

    mkdir -p $dest
    cd $dest
 
   # if there is no .git folder then it is a first split we clone repo
    if [ ! -d ".git" ]; then
       echo "----"
       echo "Repository not initialized"
       echo ""
        git init
        git remote add splited $repo
       echo "Repository initialized. Remote defined to $repo"
       echo ""
    fi

    # we get master
    echo "----"
    echo "fetch all"
    git fetch --all -p

    echo "----"
    echo "checkout and pull master branch"
    echo ""
    git checkout master
    git pull splited master

    # get local branch changes to master
    nbcommit=$(git rev-list $PATH_MONOREPO...$branch --count)
    echo "----"
    echo "found $nbcommit to merge"
    echo ""
    
    if [$nbcount != 0]; then
	git pull --no-ff $PATH_MONOREPO $branch --no-edit

    	# edit last message
	echo "----"
	echo "Update merge message"
	echo ""
	#TODO build a better message
	git amend -F- <<EOF
(split) Splited from sgp/smart-answer

CHANGELOG: Automaticaly merged with split.sh
EOF

        # push to master
	echo "----"
	echo "Push to $repo / master"
	echo ""
	git push -u splited master
    fi

    cd $PATH_MONOREPO

    echo "----"
    echo "Done"
    echo ""
}


## display help if any
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ ! -d ".git" ]; then
    echo "----"
    echo "not in root folder of project"
    echo ""
    usage
    exit
fi

dosplits(){
    echo "----"
    echo "Processing"
    echo ""
    # Put calls to split here
    # TODO read config from a config file
    #split '{destination}' '{path}' '{branch}' '{remote}'
}

while true; do
    read -p "This is WIP program are you sure you want to continue?" yn
    case $yn in
        [Yy]* ) dosplits; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

exit 0


