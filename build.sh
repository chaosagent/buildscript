#
#  Copyright (c) 2013 David Hou
#
#  Licensed under GPLv3.
#  Read more about it at http://gplv3.fsf.org/
#  Essentially, it says that you can do anything you want with the script and redistribute it (you can even sell it!), but you have to provide it's source code on request.
#

confdir=~/.androidbuild

function main {
	while [ True ]
	do
		echo "What do you want to do?"
		echo "  a) Initialize a ROM repository"
		echo "  b) Enter a ROM repository"
		echo "  c) Quit"
		while [ True ]
		do
			read todo
			case $todo in 
				a) repoinit;;
				b) torepo;;
				c) exit;;
				*) echo "Please enter the letter of the option you want";;
			esac
		done
	done
}

function setupEnv {
	mkdir $confdir 2>/dev/null
	echo "Setting up build environment. I will need root access to install packages for this."
	sudo echo "Installing packages. This might take a while, depending on your internet speed. It also might ask you for your password again because it takes so long."
	sudo apt-get install openjdk-6-jdk python git-core git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev x11proto-core-dev libx11-dev libreadline6-dev libgl1-mesa-glx libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev > /dev/null 2>&1
	sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
	sudo echo '#Acer
SUBSYSTEM=="usb", ATTR{idVendor}=="0502", MODE="0666"

#ASUS
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", MODE="0666"

#Dell
SUBSYSTEM=="usb", ATTR{idVendor}=="413c", MODE="0666"

#Foxconn
SUBSYSTEM=="usb", ATTR{idVendor}=="0489", MODE="0666"

#Garmin-Asus
SUBSYSTEM=="usb", ATTR{idVendor}=="091E", MODE="0666"

#Google
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666"

#HTC
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666"

#Huawei
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666"

#K-Touch
SUBSYSTEM=="usb", ATTR{idVendor}=="24e3", MODE="0666"

#KT Tech
SUBSYSTEM=="usb", ATTR{idVendor}=="2116", MODE="0666"

#Kyocera
SUBSYSTEM=="usb", ATTR{idVendor}=="0482", MODE="0666"

#Lenevo
SUBSYSTEM=="usb", ATTR{idVendor}=="17EF", MODE="0666"

#LG
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666"

#Motorola
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666"

#NEC
SUBSYSTEM=="usb", ATTR{idVendor}=="0409", MODE="0666"

#Nook
SUBSYSTEM=="usb", ATTR{idVendor}=="2080", MODE="0666"

#Nvidia
SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0666"

#OTGV
SUBSYSTEM=="usb", ATTR{idVendor}=="2257", MODE="0666"

#Pantech
SUBSYSTEM=="usb", ATTR{idVendor}=="10A9", MODE="0666"

#Philips
SUBSYSTEM=="usb", ATTR{idVendor}=="0471", MODE="0666"

#PMC-Sierra
SUBSYSTEM=="usb", ATTR{idVendor}=="04da", MODE="0666"

#Qualcomm
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666"

#SK Telesys
SUBSYSTEM=="usb", ATTR{idVendor}=="1f53", MODE="0666"

#Samsung
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666"

#Sharp
SUBSYSTEM=="usb", ATTR{idVendor}=="04dd", MODE="0666"

#Sony Ericsson
SUBSYSTEM=="usb", ATTR{idVendor}=="0fce", MODE="0666"

#Toshiba
SUBSYSTEM=="usb", ATTR{idVendor}=="0930", MODE="0666"

#ZTE
SUBSYSTEM=="usb", ATTR{idVendor}=="19D2", MODE="0666"' > /etc/udev/rules.d/51-android.rules
	sudo chmod a+r /etc/udev/rules.d/51-android.rules
	installing the repo tool...
	curl http://git-repo.googlecode.com/files/repo-1.19 > $confdir/repo > /dev/null 2>&1
	chmod a+x $confdir/repo
	echo PATH=~/bin:$PATH >> .profile
	echo "Build environment setup done"
	break
}

function repoinit {
	while [ True ]
	do
		echo "What is the name of the ROM you want to set up?"
		read romname
		if [ $(echo $romname | grep " ") ]
		then
			echo "Please do not put a space in the name"
		else
			break
		fi
	done
	echo "Enter the GitHub link of the manifest of the ROM. It is usually named android or platform_manifest or manifest."
	read manifestlink
	echo "What is the name of the branch you want to download? It is on the top right corner of the page under the name and the bar that says commits."
	read rombranch
	echo "Initializing repo..."
	romdir=$romname\_$rombranch
	echo $romname > $confdir/roms
	echo $rombranch > $confdir/rombranch
	echo $romdir > $confdir/romdirs
	mkdir $romdir
	cd $romdir
	repo init -u $manifestlink -b $rombranch > /dev/null 2>&1
	echo "Downloading the source code. This will take a LOOOONNNNGGGG time (It has to download over 30 gigabytes of code)"
	reposync
	echo "Repo initialized and source downloaded."
	break
}

function torepo {
	echo "Choose a repository:"
	if [ -f $confdir/repos ]
	then
		for reponame in $(cat $confdir/repos)
		do
			echo $reponame
		done
		while [ True ]
		do
			read reponame
			if [ $(grep $reponame $confdir/romdirs) ]
			then
				cd $(grep $reponame $confdir/romdirs)
				repo
				main
			else
				echo "There is no such repo of that name"
			fi
		done
	else
		echo "You do not have any existing repositories known to this script."
		break
	fi
}

function repo {
	. build/envsetup.sh > /dev/null 2>&1
	while [ True ]
	do
		echo "What would you like to do?"
		echo "  a) Add a device"
		echo "  b) Build"
		echo "  c) Remove output files"
		echo "  d) Synchronize repo"
		echo "  e) Back"
		read todo
		case $todo in
			a) adddevice;;
			b) build;;
			c) clobber;;
			d) reposync;;
			e) break;;
			*) echo "Please enter the letter of the option you want";;
		esac
	done
	break
}

function reposync {
	repo sync
	break
}

function adddevice {
	# TODO: Write assimilation script
	echo "This feature is not yet supported."
	break
}

function build {
	lunch
	make -j$(cat /proc/cpuinfo | grep processor | wc -l) otapackage 1 > $confdir/last_buildlog 2>&1
	if [ $? == 0 ]
	then
		echo "Build completed successfully"
		break
	else
		echo "Build Failed. Would you like to see the build log? (y/n)"
		read seelog
		case $seelog in
			y) nano $confdir/last_buildlog;;
			*) break;;
		esac
	fi
}

function clobber {
	make clobber
	break
}

# This happens on init. It's at the bottom because bash requires functions to be linearly defined before they are used
if [ ! -d $confdir ]
then
	echo "Do you already have an existing build environment? (y/n)"
	while [ True ]
	do
		read haveenv
		case "$haveenv" in
			y) mkdir $confdir && main;;
			n) setupEnv;;
			*) echo "Please enter either y or n";;
		esac
	done
else
	main
fi
