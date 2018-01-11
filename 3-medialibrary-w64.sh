#!/bin/bash
# Based on medialibrary-win64
set -x

IMAGE_DATE=201712141608

TARGET_TRIPLE=x86_64-w64-mingw32
SQLITE_VERSION=sqlite-autoconf-3140000
JPEGTURBO_VERSION=1.5.0

TARGET_TUPLE=x86_64-w64-mingw32
TOOLCHAIN_PREFIX=/opt/gcc-$TARGET_TUPLE
MINGW_PREFIX=$TOOLCHAIN_PREFIX/$TARGET_TUPLE
PATH=$TOOLCHAIN_PREFIX/bin:$PATH
GCC_VERSION=6.4.0
BINUTILS_VERSION=2.27
MPFR_VERSION=3.1.6
GMP_VERSION=6.1.1
MPC_VERSION=1.0.3

rm -rf /build
mkdir /build
cd /build
#git clone --depth=1 https://git.videolan.org/git/vlc.git
git clone --depth=1 https://github.com/kc7bfi/vlc.git
cd vlc
cd extras/tools
./bootstrap
make -j`nproc`
export PATH=`pwd`/build/bin:$PATH
cd ../../
cd contrib
mkdir win64
cd win64
../bootstrap --host=$TARGET_TRIPLE --disable-qt --disable-skins2 --disable-lua --disable-protobuf --disable-gettext
make -j`nproc`
cd /build/vlc
./bootstrap
mkdir build
cd build
../configure --host=$TARGET_TRIPLE --disable-lua --disable-qt --disable-skins2 --disable-nls --disable-d3d11va --prefix=/prefix
make -j`nproc` || { echo 'VLC build failed' ; exit 1; }
make install || { echo 'VLC install failed' ; exit 1; }
mkdir -p /prefix/dll
cp src/.libs/libvlccore.dll /prefix/dll/
cp lib/.libs/libvlc.dll /prefix/dll
make package-win32-zip || { echo 'VLC package failed' ; exit 1; }
cd /build
wget https://www.sqlite.org/2016/$SQLITE_VERSION.tar.gz
tar xzf $SQLITE_VERSION.tar.gz
cd $SQLITE_VERSION
./configure --prefix=/prefix --host=$TARGET_TRIPLE --disable-shared
make -j`nproc`
make install
cd /build
wget http://downloads.sourceforge.net/project/libjpeg-turbo/1.5.0/libjpeg-turbo-$JPEGTURBO_VERSION.tar.gz
tar xzf libjpeg-turbo-$JPEGTURBO_VERSION.tar.gz
cd libjpeg-turbo-$JPEGTURBO_VERSION
./configure --host=$TARGET_TRIPLE --prefix=/prefix --disable-shared
make -j`nproc`
make install
cd /build
wget https://github.com/miloyip/rapidjson/archive/v1.0.2.tar.gz
tar xzf v1.0.2.tar.gz
cd rapidjson-1.0.2/
cmake -DCMAKE_INSTALL_PREFIX=/prefix -DRAPIDJSON_BUILD_DOC=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF -DRAPIDJSON_BUILD_TESTS=OFF .
make install



