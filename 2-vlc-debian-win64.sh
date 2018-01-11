#!/bin/bash
# based on v vlc-winrt-x86_64
set -x

IMAGE_DATE=201712211538

apt-get update
apt-get install --yes git wget bzip2 file libwine-dev unzip libtool pkg-config cmake build-essential automake texinfo ragel yasm p7zip-full autopoint gettext flex bison dos2unix zip wine nsis gperf
echo "deb http://deb.debian.org/debian experimental main" > /etc/apt/sources.list.d/experimental.list
apt-get update
apt-get -y -t experimental install nsis
rm -f /etc/apt/sources.list.d/experimental.list
apt-get clean -y
rm -rf /var/lib/apt/lists/*

TARGET_TUPLE=x86_64-w64-mingw32
TOOLCHAIN_PREFIX=/opt/gcc-$TARGET_TUPLE
MINGW_PREFIX=$TOOLCHAIN_PREFIX/$TARGET_TUPLE
PATH=$TOOLCHAIN_PREFIX/bin:$PATH
GCC_VERSION=6.4.0
BINUTILS_VERSION=2.27
MPFR_VERSION=3.1.6
GMP_VERSION=6.1.1
MPC_VERSION=1.0.3

mkdir /Downloads

rm -rf /build
mkdir /build/
cp -rf patches /build
cd /build
mkdir $TOOLCHAIN_PREFIX
mkdir $MINGW_PREFIX
ln -s $MINGW_PREFIX $TOOLCHAIN_PREFIX/mingw
if [ ! -f /Downloads/binutils-$BINUTILS_VERSION.tar.bz2 ]; then
	wget --directory-prefix=/Downloads http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.bz2
fi
if [ ! -f /Downloads/gcc-$GCC_VERSION.tar.xz ]; then
	wget --directory-prefix=/Downloads ftp://ftp.uvsq.fr/pub/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz
fi
git config --global user.name "VideoLAN Buildbot"
git config --global user.email buildbot@videolan.org
git clone --depth=1 git://git.code.sf.net/p/mingw-w64/mingw-w64
tar xf /Downloads/gcc-$GCC_VERSION.tar.xz
tar xf /Downloads/binutils-$BINUTILS_VERSION.tar.bz2
cd binutils-$BINUTILS_VERSION
mkdir build
cd build
../configure --prefix=$TOOLCHAIN_PREFIX --target=$TARGET_TUPLE --disable-werror --disable-multilib
make -j`nproc`
make install
cd /build/mingw-w64
git am /build/patches/*.patch
cd /build/mingw-w64/mingw-w64-headers
mkdir build
cd build
../configure --prefix=$MINGW_PREFIX --host=$TARGET_TUPLE --enable-secure-api
make install
cd /build
if [ ! -f /Downloads/mpfr-$MPFR_VERSION.tar.gz ]; then
	wget --directory-prefix=/Downloads -q http://www.mpfr.org/mpfr-$MPFR_VERSION/mpfr-$MPFR_VERSION.tar.gz
fi
if [ ! -f /Downloads/gmp-$GMP_VERSION.tar.xz ]; then
	wget --directory-prefix=/Downloads -q https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.xz
fi
if [ ! -f /Downloads/mpc-$MPC_VERSION.tar.gz ]; then
	wget --directory-prefix=/Downloads -q ftp://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz
fi
tar xf /Downloads/mpfr-$MPFR_VERSION.tar.gz || { echo "Download mpfr-$MPFR_VERSION" ; exit 1; }
tar xf /Downloads/gmp-$GMP_VERSION.tar.xz || { echo "Download gmp-$GMP_VERSION" ; exit 1; }
tar xf /Downloads/mpc-$MPC_VERSION.tar.gz || { echo "Download mpc-$MPC_VERSION" ; exit 1; }
ln -s /build/mpfr-$MPFR_VERSION gcc-$GCC_VERSION/mpfr
ln -s /build/gmp-$GMP_VERSION gcc-$GCC_VERSION/gmp
ln -s /build/mpc-$MPC_VERSION gcc-$GCC_VERSION/mpc
sed -i '79i#define _GLIBCXX_USE_WEAK_REF 0' gcc-$GCC_VERSION/libstdc++-v3/config/os/mingw32-w64/os_defines.h
cd gcc-$GCC_VERSION
mkdir build
cd build
../configure --prefix=$TOOLCHAIN_PREFIX --target=$TARGET_TUPLE --enable-languages=c,c++ --enable-lto --disable-shared --disable-multilib --enable-sjlj-exceptions
make -j`nproc` all-gcc || { echo 'Make all-gcc failed' ; exit 1; }
make install-gcc
cd /build/mingw-w64/mingw-w64-crt
mkdir build
cd build
../configure --prefix=$MINGW_PREFIX --host=$TARGET_TUPLE
make -j`nproc`
make install
cd /build/gcc-$GCC_VERSION/build
make -j`nproc`
make install
cd /build/mingw-w64/mingw-w64-libraries/winstorecompat
autoreconf -vif
mkdir build
cd build
../configure --prefix=$MINGW_PREFIX --host=$TARGET_TUPLE
make -j`nproc`
make install
cd /build/mingw-w64/mingw-w64-tools/widl
mkdir build
cd build
../configure --prefix=$TOOLCHAIN_PREFIX --target=$TARGET_TUPLE
make -j`nproc`
ls
make install
cd /


