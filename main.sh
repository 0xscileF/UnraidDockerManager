#!/bin/bash

if [ ! -d "out" ]; then
	mkdir out
fi

checkPackage () {
TARGET_PACKAGE=$1
BASE_URL="https://archlinux.org/packages/?sort=&q="
AUR_URL="https://aur.archlinux.org/rpc/?v=5&type=search&by=name&arg="
REQUEST_URL=$BASE_URL$TARGET_PACKAGE


echo "Searching for $TARGET_PACKAGE in Core/Extra..."
response=$(curl -s "$REQUEST_URL" | grep exact-matches)

if [ ! -z "$response" ]; then
        repo=$(curl -s "$REQUEST_URL" | grep exact-matches -A30 | grep -E 'Core|Extra|Community')
	repo="${repo//"</td>"/}"
        repo="${repo//"<td>"/}"
        repo=$(echo "$repo" | xargs)
        if [ "$repo" = "Community" ]; then
                isAur=True 
        fi
        TOINSTALL=$TARGET_PACKAGE
else
echo "Searching for $TARGET_PACKAGE in Community..."
REQUEST_URL=$AUR_URL$TARGET_PACKAGE

response=$(curl -s "$REQUEST_URL" | jq '.results | map(.Name) ')
response=${response#'['}
response=${response%']'}
response=$(echo $response | xargs)

if [ ! -z "$response" ]; then
        IFS=', ' read -r -a array <<< "$response"
        count=${#array[@]}
        if [ $count -gt 1 ]; then
                echo "Possible Candidates:"
                for i in $response; do
			name=$(echo $i | cut -c 1- | rev | cut -c2- | rev)
			echo "$name"
			if [ $name = $TARGET_PACKAGE ]; then
				TOINSTALL=$name
				isAur=True
				break
			fi
			
                done
        elif [ $count -eq 1 ]; then
                TOINSTALL=$name
                isAur=True
        else
                # echo "No Package Candidate was found. Check spelling and try agian."
		echo "Neither '$TARGET_PACKAGE' nor possible candidates were found in 'Core/Extra/Community'"
                exit 1
        fi
fi
fi
}

checkPackage "$1"
PACMAN_PKG=""
YAY_PKG=""
if [ -z $TOINSTALL ]; then
	exit 1
else
	echo "Wanted $TARGET_PACKAGE Got: $TOINSTALL"
	if [ -z $isAur ]; then
		echo "Replacing in pacman"
		PACMAN_PKG=$TOINSTALL
	else
		echo "Replacing in yay"
		YAY_PKG=$TOINSTALL
	fi	
fi
#exit 0
BASEDIR=/boot/config/UnraidDockerManager
BUILD_DIR="out/arch-$TOINSTALL"
#  copy base
if [ ! -d "$BUILD_DIR" ]; then
	cp -r arch-base $BUILD_DIR
else
	cp arch-base/build/root/install.sh $BUILD_DIR/build/root/
fi
cp base.xml out/$TOINSTALL.xml

# Get PKGBUILD 
if [ -z $isAur ]; then
	PKGBUILD=$(curl -s "https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/$TOINSTALL/trunk/PKGBUILD")
else
	PKGBUILD=$(curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$TOINSTALL") 
fi	






# Get default execpath
EXEC_PATH=$(echo "$PKGBUILD" | egrep "*ln -s*" | grep "/usr/bin" | xargs |cut -d ' ' -f4  | sed s/\$pkgdir// | sed 's/\$pkgname//' | sed 's/\${pkgdir}//' | sed 's/\${pkgname}//' | sed 's/\/\//\//')
echo "Exec path should  be $EXEC_PATH"

# Get favicon of upstream url
ICONURL=$(echo "$PKGBUILD" | grep -m1 "url" | sed s/url=// |cut -c2- | rev | cut -c2- | rev | sed -r 's#([^/])/[^/].*#\1#')/favicon.ico
echo "ICONURL=$ICONURL"

curl -o $BUILD_DIR/config/nobody/novnc-16x16.png "$ICONURL"

sed -i -e "s/BASE_APPNAME/$TOINSTALL/g" $BUILD_DIR/build/root/install.sh

sed -i -e "s/PACMAN_PKG/$PACMAN_PKG/g" $BUILD_DIR/build/root/install.sh

sed -i -e "s/YAY_PKG/$YAY_PKG/g" $BUILD_DIR/build/root/install.sh
# use | as delimeter as EXEC_PATH contains '/'

sed -i -e "s|EXEC_PATH|$EXEC_PATH|g" $BUILD_DIR/build/root/install.sh
NEXTPORT=`expr  $(cat ports) + 1`

# Need to change  base xml to put registry felix/

sed -i -e "s/BASE_APPNAME/$TOINSTALL/g" out/$TOINSTALL.xml

sed -i -e "s/BASE_PORT/$NEXTPORT/g" out/$TOINSTALL.xml

sed -i -e "s|BASE_ICON|$ICONURL|g" out/$TOINSTALL.xml
# keep track of used docker ports in list and set them accordingly in template file

cd $BUILD_DIR

docker build -t felix/$TOINSTALL .
# Maybe omit the run command and just past the xml?
# docker run -d -p 5900:5900 -p 6080:6080 --name=$1 --security-opt seccomp=unconfined -v /mnt/user/appdata/data:/data -v /mnt/user/appdata/felix-$1:/config -v /etc/localtime:/etc/localtime:ro -e WEBPAGE_TITLE=$1 -e VNC_PASSWORD=mypassword -e UMASK=000 -e PUID=99 -e PGID=100 felix/$1

cd $BASEDIR

cp out/$TOINSTALL.xml /boot/config/plugins/dockerMan/templates-user/my-felix-$TOINSTALL.xml
echo $NEXTPORT > ports
rm -r out/*
