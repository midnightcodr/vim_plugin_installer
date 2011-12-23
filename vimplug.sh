#!/bin/bash
# This is a bash script that installs some very cool vim plugins.
# Collection is based on
# http://www.fortystones.com/vim-plugins-web-developers-programmers/

tmp_dir=/tmp/`mktemp -u XXXXX`.`date +%Y%m%d%H%M%S`
dest_dir=~/.vim


plugins=(
	"Snipmate|http://www.vim.org/scripts/download_script.php?src_id=11006|snipMate.zip|0.83"
	"Surround|http://www.vim.org/scripts/download_script.php?src_id=12566|surround.zip|1.90"
	"Matchit|http://www.vim.org/scripts/download_script.php?src_id=8196|matchit.zip|1.13.2"
)
downloaders=(wget curl)
downloaders_fmts=("-N -O%s -q %s" "-s -o %s %s") 

function prepare() {
	echo "Creating temporary directory [ $tmp_dir ]"
	[ -d $tmp_dir ] || mkdir -p $tmp_dir
	[ -d $dest_dir ] || mkdir -p $dest_dir
}

function cleanup() {
	echo "Removing temporary directory $tmp_dir"
	rm -rf $tmp_dir
}

function install() {
	prepare
	if [ $? -ne 0 ]; then
		"Creating $tmp_dir or $dest_dir failed."
		exit 103
	fi
	for p in ${plugins[@]}; do
		name=`echo $p|cut -d '|' -f1`
		url=`echo $p|cut -d '|' -f2`
		zip=$tmp_dir/`echo $p|cut -d '|' -f3`
		echo "Downloading $name plugin from $url"
		printf "$downloader_fmt" $zip $url|bash
		echo "Installing $name plugin to $dest_dir"
		unzip -oq -d $dest_dir $zip && echo "Installation of $name is successful" || echo "Installation of $name failed."
		echo 
	done
	cleanup
}

function usage() {
	cat <<EOL
This is a bash script that installs some very cool vim plugins.  Collection is based on
http://www.fortystones.com/vim-plugins-web-developers-programmers/

Usage: $0 install|list

For most of the plugins to work, please have the following option set in your ~/.vimrc
if you haven't done so yet

filetype plugin on
EOL
}

function list() {
	# list plugins that will be installed
	for p in ${plugins[@]}; do
		name=`echo $p|cut -d '|' -f1`
		url=`echo $p|cut -d '|' -f2`
		zip=`echo $p|cut -d '|' -f3`
		version=`echo $p|cut -d '|' -f4`
		echo "Name: $name, url: $url, zip: $zip, verson: $version"
	done
}

if [ $# -lt 1 ] || [[ ! $1 =~ ^(install|list)$ ]]; then
	usage
	exit 101
fi



downloader_fmt=
ind=0
for d in "${downloaders[@]}"; do
	downloader=`which $d`
	if [ -n "$downloader" ]; then
		downloader_fmt="$downloader ${downloaders_fmts[$ind]}"
		break;
	fi
	let ind=ind+1
done
if [ -z "$downloader_fmt" ]; then
	printf "None of the following download program exists, exit now\n"
	printf "${downloaders[@]}\n"
	exit 102
fi
$1
