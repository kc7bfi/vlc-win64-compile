#!/bin/bash
# Based on vlc-debian-win64
set -x

TARGET_TUPLE=x86_64-w64-mingw32
TOOLCHAIN_PREFIX=/opt/gcc-$TARGET_TUPLE
MINGW_PREFIX=$TOOLCHAIN_PREFIX/$TARGET_TUPLE
PATH=$TOOLCHAIN_PREFIX/bin:$PATH
GCC_VERSION=6.4.0
BINUTILS_VERSION=2.27
MPFR_VERSION=3.1.6
GMP_VERSION=6.1.1
MPC_VERSION=1.0.3
SHORTARCH=x86_64 

rm -rf /build
mkdir /build
cd /build
git clone --no-checkout https://git.videolan.org/git/vlc.git
cd vlc
git checkout e305b509dc6ff26fa7bac0020d700ac0eda725dd

sed -i -e "s^protobuf.googlecode.com/svn/rc^github.com/google/protobuf/releases/download/v2.6.0^g" /build/vlc/contrib/src/protobuf/rules.mak
sed -i -e "s^download.osgeo.org/libtiff^ftp.osuosl.org/pub/blfs/conglomeration/tiff^g" /build/vlc/contrib/src/tiff/rules.mak
sed -i -e "s^protobuf.googlecode.com/svn/rc^github.com/google/protobuf/releases/download/v2.6.0^g" /build/vlc/extras/tools/packages.mak
sed -i -e "s^heanet.dl.sourceforge.net/sourceforge^sourceforge.net/projects/libcddb/files^g" /build/vlc/contrib/src/main.mak
sed -i -e "s^libcddb/libcddb-^libcddb/1.3.2/libcddb-^g" /build/vlc/contrib/src/cddb/rules.mak
sed -i -e "s^ .sum-crystalhd^^g" /build/vlc/contrib/src/crystalhd/rules.mak
sed -i -e "/sum-crystalhd/d" /build/vlc/contrib/src/crystalhd/rules.mak
sed -i -e "s^ .sum-tiff^^g" /build/vlc/contrib/src/tiff/rules.mak
sed -i -e "s^PNG_URL :=.*$^PNG_URL := https://sourceforge.net/projects/libpng/files/libpng16/older-releases/1.6.16/libpng-1.6.16.tar.xz^g" /build/vlc/contrib/src/png/rules.mak
sed -i -e "s^ZLIB_URL :=.*$^ZLIB_URL := https://www.zlib.net/fossils/zlib-1.2.8.tar.gz^g" /build/vlc/contrib/src/zlib/rules.mak
sed -i -e "s^FREETYPE2_URL :=.*$^FREETYPE2_URL := https://sourceforge.net/projects/freetype/files/freetype2/2.5.5/freetype-2.5.5.tar.gz^g" /build/vlc/contrib/src/freetype2/rules.mak
sed -i -e "s^FRIBIDI_URL :=.*$^FRIBIDI_URL := https://ftp.osuosl.org/pub/blfs/conglomeration/fribidi/fribidi-0.19.6.tar.bz2^g" /build/vlc/contrib/src/fribidi/rules.mak
sed -i -e "s^OPENJPEG_URL :=.*$^OPENJPEG_URL := https://download.videolan.org/contrib/openjpeg/openjpeg-1.5.0.tar.gz^g" /build/vlc/contrib/src/openjpeg/rules.mak
sed -i -e "s^LAME_URL :=.*$^LAME_URL := https://sourceforge.net/projects/lame/files/lame/3.99/lame-3.99.5.tar.gz^g" /build/vlc/contrib/src/lame/rules.mak
sed -i -e "s^--enable-memalign-hack^^g" /build/vlc/contrib/src/ffmpeg/rules.mak
sed -i -e "/enable-libopenjpeg/d" /build/vlc/contrib/src/ffmpeg/rules.mak
sed -i -e "8,12d" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch

echo "Building extra tools"
cd extras/tools
./bootstrap
make
PATH=$PWD/build/bin:$PATH
cd ../../

echo "Building contribs"
export USE_FFMPEG=1
mkdir -p contrib/contrib-$SHORTARCH && cd contrib/contrib-$SHORTARCH
if [ ! -z "$BREAKPAD" ]; then
     CONTRIBFLAGS="$CONTRIBFLAGS --enable-breakpad"
fi
#../bootstrap --host=$TARGET_TUPLE  --disable-qt --disable-skins2 --disable-lua --disable-protobuf --disable-gettext
../bootstrap --host=$TARGET_TUPLE --disable-cddb --disable-crystalhd

# Rebuild the contribs or use the prebuilt ones
if [ "$PREBUILT" != "yes" ]; then
make list
make fetch
make 
if [ "$PACKAGE" = "yes" ]; then
make package
fi
else
make prebuilt
make .luac
fi
cd ../..

echo "Bootstrapping"
export PKG_CONFIG_LIBDIR=$PWD/contrib/$TRIPLET/lib/pkgconfig
export PATH=$PWD/contrib/$TRIPLET/bin:$PATH
echo $PATH

./bootstrap

echo "Configuring VLC"
mkdir $SHORTARCH || true
cd $SHORTARCH

CONFIGFLAGS=""
if [ "$RELEASE" != "yes" ]; then
     CONFIGFLAGS="$CONFIGFLAGS --enable-debug"
fi
if [ "$I18N" != "yes" ]; then
     CONFIGFLAGS="$CONFIGFLAGS --disable-nls"
fi
if [ ! -z "$BREAKPAD" ]; then
     CONFIGFLAGS="$CONFIGFLAGS --with-breakpad=$BREAKPAD"
fi

../extras/package/win32/configure.sh --host=$TRIPLET --disable-lua --disable-qt --disable-skins2 --disable-nls --disable-d3d11va --prefix=/prefix

echo "Compiling"
make

if [ "$INSTALLER" = "n" ]; then
make package-win32-debug package-win32
elif [ "$INSTALLER" = "r" ]; then
make package-win32
elif [ "$INSTALLER" = "u" ]; then
make package-win32-release
sha512sum vlc-*-release.7z
fi
