#!/bin/bash

echo "Enter Theme Name"
read Themename

cp -r Windows-XP $Themename





echo "Making computer icons"

for f in custom-icons/computer.png
do
cp $f $Themename/128x128/places/computer.png
    magick $f -resize 48x48 $Themename/48x48/places/computer.png
    magick $f -resize 24x24 $Themename/24x24/places/computer.png
    magick $f -resize 22x22 $Themename/22x22/places/computer.png
    magick $f -resize 16x16 $Themename/16x16/places/computer.png
done

echo "Making document icons"

for f in custom-icons/documents.png
do
cp $f $Themename/128x128/places/
    magick $f -resize 48x48 $Themename/48x48/places/user-documents.png
    magick $f -resize 24x24 $Themename/24x24/places/user-documents.png
    magick $f -resize 22x22 $Themename/22x22/places/user-documents.png
    magick $f -resize 16x16 $Themename/16x16/places/user-documents.png
done

echo "Making trash icons"

for f in custom-icons/trash.png
do
    magick $f -resize 48x48 $Themename/48x48/places/user-trash-full.png
    magick $f -resize 48x48 $Themename/48x48/places/user-trash-full.png
    magick $f -resize 24x24 $Themename/24x24/places/user-trash.png
    magick $f -resize 22x22 $Themename/22x22/places/user-trash.png
    magick $f -resize 16x16 $Themename//16x16/status/user-trash-full.png
    magick $f -resize 16x16 $Themename/16x16/places/emptytrash.png
done

echo "Making network icons"

for f in custom-icons/network.png
do
cp $f $Themename/128x128/devices/gnome-fs-client.png
cp $f $Themename/128x128/devices/gnome-remote-desktop.png
cp $f $Themename/128x128/places/network-workgroup.png
cp $f $Themename/128x128/places/network-server.png
cp $f $Themename/128x128/places/gnome-fs-server.png

    magick $f -resize 48x48 $Themename/48x48/places/gnome-fs-client.png
    magick $f -resize 48x48 $Themename/48x48/places/gnome-remote-desktop.png
    magick $f -resize 48x48 $Themename/48x48/places/gnome-fs-server.png
    magick $f -resize 48x48 $Themename/48x48/places/network-server.png
    magick $f -resize 48x48 $Themename/48x48/places/network-workgroup.png

    magick $f -resize 24x24 $Themename/24x24/places/gnome-fs-client.png
    magick $f -resize 24x24 $Themename/24x24/places/gnome-remote-desktop.png
    magick $f -resize 24x24 $Themename/24x24/places/gnome-fs-server.png
    magick $f -resize 24x24 $Themename/24x24/places/network-server.png
    magick $f -resize 24x24 $Themename/24x24/places/network-workgroup.png

    magick $f -resize 22x22 $Themename/22x22/places/gnome-fs-client.png
    magick $f -resize 22x22 $Themename/22x22/places/gnome-remote-desktop.png
    magick $f -resize 22x22 $Themename/22x22/places/gnome-fs-server.png
    magick $f -resize 22x22 $Themename/22x22/places/network-server.png
    magick $f -resize 22x22 $Themename/22x22/places/network-workgroup.png

    magick $f -resize 16x16 $Themename/16x16/places/gnome-fs-client.png
    magick $f -resize 16x16 $Themename/16x16/places/gnome-remote-desktop.png
    magick $f -resize 16x16 $Themename/16x16/places/gnome-fs-server.png
    magick $f -resize 16x16 $Themename/16x16/places/network-server.png
    magick $f -resize 16x16 $Themename/16x16/places/network-workgroup.png
    magick $f -resize 22x22 $Themename/22x22/devices/network-server.png


done
sed -i "s/^Name=Windows XP$/Name=$Themename/" $Themename/index.theme
cp -r $Themename ~/.icons

echo ".done"


#cp -r --update=none Windows-XP/* $ThemeName 


#gtk-network.png
#gnome-mime-x-directory-smb-workgroup.png
#128x128/places/gnome-remote-desktop.png

#128x128/devices/gnome-fs-client.png
#48x48/places/user-trash-full.png
#48x48/places/emptytrash.png

