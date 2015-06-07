#!/usr/bin/env bash
set -ex
cd $(dirname $0)/..
export W="${PWD}"
export PACKAGE="lxcfs"
#export PPA="${PACKAGE}"
export PPA="lxc"
#export REPO="git://git.debian.org/git/pkg-utopia/${PACKAGE}.git"
export REPO=""
export DEBEMAIL=${DEBEMAIL:-kiorky@cryptelium.net}
export KEY="${KEY:-0x5616F8C2}"
export VER=${VER:-"$(grep -r AC_INIT  configure.ac |awk '{print $2}'|sed -re "s/.*\[//g" -e "s/\].*//g")"}
export FLAVORS="precise trusty vivid"
export FLAVORS="trusty vivid"
export RELEASES="${RELEASES:-"14\.10|15\.04|14\.04|experimental|stable|unstable|precise|trusty|utopic|vivid|oneric|wily"}"
if [ "x${VER}" = "x" ];then echo unknownversion;exit -1;fi
if [ "x${REPO}" != "x" ];then
    if [ ! -e "${W}/../debian-up" ];then git clone "${REPO}" "${W}/../debian-up";fi
    cd "${W}/"../debian-up && rm -rf * && git fetch --all && git reset --hard origin/master
    rsync -av --delete --exclude=changelog "${W}/../debian-up/debian/" "${W}/debian/"
fi
if [ -e "${W}/mc_packaging/debian/" ];then
    rsync -av "${W}/mc_packaging/debian/" "${W}/debian/"
fi
#
# CUSTOM MERGE CODE HERE
# <>
#
echo "3.0 (native)">"${W}/debian/source/format"
cd "${W}"
CHANGES=""
if [ -e $HOME/.gnupg/.gpg-agent-info ];then . $HOME/.gnupg/.gpg-agent-info;fi
# make a release for each flavor
logfile=../log
if [ -e "${logfile}" ];then rm -f "${logfile}";fi
if [ -e "${logfile}.pipe" ];then rm -f "${logfile}.pipe";fi
mkfifo "${logfile}.pipe"
tee < "${logfile}.pipe" "$logfile" &
exec 1> ${logfile}.pipe 2> ${logfile}.pipe
for i in ${FLAVORS};do
    sed  -i -re "1 s/${PACKAGE} \([0-9].[0-9]+(.[0-9]+)*(-(${RELEASES}))?([^)]*\).*)((${RELEASES});)(.*)/${PACKAGE} (${VER}-${i}\4${i};\7/g" debian/changelog
    dch -i -D ${i} "packaging for ${i}"
    debuild -k"${KEY}" -S -sa --lintian-opts -i
done
rm "${logfile}.pipe"
exec 1>&1
egrep "signfile" log|sed "s///g"
CHANGES=$(grep "signfile " ../log|awk '{print  $2}'|grep source.changes)
rm -f log
# upload to final PPA
cd "${W}"
for i in ${CHANGES};do dput "${PPA}" "../${i}";done
# vim:set et sts=4 ts=4 tw=0:
