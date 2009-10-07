#!/bin/bash
#     Script to convert from Axe's tarball to ipk
#
# Depends on ipkg-build, and input file nunome-Qtopia-zaurus.tar.gz
#  available from: 
#  http://www.sikigami.com/nunome-Qtopia-1.0/
#should figure out correct answer to questionaire: is SL-5k PDA Linux or Zaurus?
#
# Created ipk depends on qpf-cyberbit-120-50-t10 
# Requires 3.9meg on PDA, plus the 3.5meg for above cyberbit font.
#
# BUGS: grep for should
#should call fakeroot or some such to eliminate need to run ipkg-build as root.
#
# created by Howard Abbey. http://hrabbey.webhop.net/Projects/Zi18n/NunomeIpk/
#
###
#cd /tmp/SomeSafeDir
mkdir nunome-Qtopia-zaurus
cd nunome-Qtopia-zaurus
tar -xzf ../nunome-Qtopia-zaurus.tar.gz
# get version
LIBFILE=`ls -F opt/QtPalmtop/plugins/inputmethods/libqNunome.so* | grep -v "@" | sed "s/*//" `
VERSION=`basename $LIBFILE | sed s/libqNunome.so.//`
cd ..
mv nunome-Qtopia-zaurus nunome_$VERSION
cd nunome_$VERSION
##
# To allow ipkg installation to vfat based flash:
#  wastes 264k.  Insignificant compared to dic size of 3.2meg.
MAJOR=`echo $VERSION | cut --delimiter=. -f 1`
MINOR=`echo $VERSION | cut --delimiter=. -f 2`
#MINI=`echo $VERSION | cut --delimiter=. -f 3`
rm opt/QtPalmtop/plugins/inputmethods/libqNunome.so.$MAJOR.$MINOR
cp opt/QtPalmtop/plugins/inputmethods/libqNunome.so.$VERSION  \
   opt/QtPalmtop/plugins/inputmethods/libqNunome.so.$MAJOR.$MINOR
rm opt/QtPalmtop/plugins/inputmethods/libqNunome.so.$MAJOR
cp opt/QtPalmtop/plugins/inputmethods/libqNunome.so.$VERSION  \
   opt/QtPalmtop/plugins/inputmethods/libqNunome.so.$MAJOR
rm opt/QtPalmtop/plugins/inputmethods/libqNunome.so
cp opt/QtPalmtop/plugins/inputmethods/libqNunome.so.$VERSION  \
   opt/QtPalmtop/plugins/inputmethods/libqNunome.so
#
#
# Instal location now taken care of by ipkg.
rm install-cf.sh install-sd.sh
##
# Tarball includes 2 other ipk's.  Cut (one of ) them out.
rm usr/lib/ipkg/status
# cyberbit font available as a seperate ipk.
rm usr/lib/fonts/cyberbit_120_50_t10.qpf
rmdir usr/lib/fonts/
rm usr/lib/ipkg/info/qpf-cyberbit-120-50-t10.list
# qpe-i18n-ja available as ipk, but it didn't work for me last time...
#  Needed something it depended on?  
#  Lang. app wasn't part of standard Zaurus ROM
#  should investigate and use seperate ipk.
#  but for now leave included
#  should use same ipk in opie as well, since much better than current.
#cat usr/lib/ipkg/info/qpe-i18n-ja.list | sed "s/^\///g" | xargs rm
rm usr/lib/ipkg/info/qpe-i18n-ja.list
rmdir usr/lib/ipkg/info
rmdir usr/lib/ipkg
rmdir usr/lib/
mkdir CONTROL
# should have a maintainer, someone employed by Axe.
# should depend on qpe-i18n-ja, not provide it.
# should work with opie-i18n-ja as well?
# should depend on qpe-language, not provide it?  Where is it?
# should conflict with opie-language.
cat <<EOF > CONTROL/control
Package: nunome
Priority: optional
Version: $VERSION
Architecture: arm
Maintainer: none 
Section: Settings
Provides: qpe-i18n-ja
Depends: qpf-cyberbit-120-50-t10
Description: Nunome.  Japanese input method from Axe.  
 More info available from http://www.sikigami.com/
EOF
cd ..
./ipkg-build nunome_$VERSION
# should chown files: "
#*** Warning: The following files have a UID greater than 99.
#You probably want to chown these to a system user: 
# "
rm -r nunome_$VERSION
