#!/bin/sh -e

# URL to Firefox binary.
FF_URL="https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=da"

# Get the latest version of Firefox available.
LATEST_VERSION=$(wget --spider -S --max-redirect 0 $FF_URL 2>&1 | sed -n '/Location: /{s|.*/firefox-\(.*\)\.tar.*|\1|p;q;}')

BASE_DIR=$(dirname `realpath $0`)/ff

# Install path for Firefox.
FF_PATH=$BASE_DIR/opt/Mozilla

# Make install path if missing.
if [ ! -d "$FF_PATH" ]; then
	mkdir -p $FF_PATH
fi

# Get the current version.
if [ -e $FF_PATH/firefox/application.ini ]; then
	CURRENT_VERSION=$(sed -n -e 's/^\s*Version\s*=\s*//p' $FF_PATH/firefox/application.ini)
else
	CURRENT_VERSION="0.0.0"
fi

if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
	echo "Found an outdated version of firefox \"$CURRENT_VERSION\"."
	echo "Downloading lates version of firefox \"$LATEST_VERSION\"."

  # Remove old binary if it exists.
	if [ -d "$FF_PATH/firefox/" ]; then
		rm -rf $FF_PATH/firefox/
	fi

  # Find any existing archives and delete them.
  for OLD_ARCHIVE in firefox*.tar*
  do
    rm -f $OLD_ARCHIVE
  done

  # Get URL for the latest Firefox version.
  ARCHIVE_URL=$(wget --spider -S --max-redirect 0 $FF_URL 2>&1 | grep "Location:" -m 1 | cut -d' ' -f4)

  # Download new Firefox archive.
	wget $ARCHIVE_URL

  # Get name of the archive file.
  FIREFOX_BIN_ARCHIVE=$(echo $ARCHIVE_URL | rev | cut -d'/' -f1 | rev)

  # Extract archive and delete it afterwards.
	tar -xvf $FIREFOX_BIN_ARCHIVE -C $FF_PATH
	rm -f $FIREFOX_BIN_ARCHIVE

  # Create icons. (Should be symbolic links...)
  for ICON in $FF_PATH/firefox/browser/chrome/icons/default/default*.png
  do
    ICON_SIZE=$(echo $ICON | rev | cut -d'/' -f1 | rev | cut -d'.' -f1 | cut -c'8-')
    ICON_INSTALL_PATH=$BASE_DIR/usr/share/icons/hicolor/"$ICON_SIZE"x"$ICON_SIZE"/apps

    # Make install path if missing.
    if [ ! -d "$ICON_INSTALL_PATH" ]; then
    	mkdir -p $ICON_INSTALL_PATH
    fi

    cp $ICON $ICON_INSTALL_PATH/firefox.png
  done

  # Make applications folder if missing.
  if [ ! -d "$BASE_DIR/usr/share/applications" ]; then
    mkdir -p $BASE_DIR/usr/share/applications
  fi

  # Insert Gnome desktop shortcut.
  cp -f Firefox.desktop $BASE_DIR/usr/share/applications/Firefox.desktop

  # Make DEBIAN folder if missing.
  if [ ! -d "$BASE_DIR/DEBIAN" ]; then
  	mkdir -p $BASE_DIR/DEBIAN
  fi

  # Generate control file.
  cp -f control.tmpl $BASE_DIR/DEBIAN/control
  sed -i "s/VERSION/$LATEST_VERSION/g" $BASE_DIR/DEBIAN/control

  # Find any existing deb files and delete them.
  for OLD_DEB in firefox*.deb*
  do
    rm -f $OLD_DEB
  done

  DPKG_NAME=firefox_"$LATEST_VERSION"_amd64.deb

  # Build Debian package.
  dpkg-deb --root-owner-group --build $BASE_DIR $DPKG_NAME

  # Clean up.
  #rm -rf $BASE_DIR

  # Change owner of the new deb file.
  chown $USERID:$GROUPID $DPKG_NAME
else
	echo "Firefox is up to date: \"$CURRENT_VERSION\""
fi
