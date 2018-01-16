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

rm -rf /build/vlc
mkdir /build
cd /build
git clone --no-checkout https://git.videolan.org/git/vlc.git
cd vlc
git checkout e305b509dc6ff26fa7bac0020d700ac0eda725dd

info "Building extra tools"
cd extras/tools
./bootstrap
make -j`nproc`
PATH=$PWD/build/bin:$PATH
cd ../../

info "Building contribs"
export USE_FFMPEG=1
mkdir -p contrib/contrib-$SHORTARCH && cd contrib/contrib-$SHORTARCH
if [ ! -z "$BREAKPAD" ]; then
     CONTRIBFLAGS="$CONTRIBFLAGS --enable-breakpad"
fi
../bootstrap --host=$TARGET_TUPLE $CONTRIBFLAGS

# Rebuild the contribs or use the prebuilt ones
if [ "$PREBUILT" != "yes" ]; then
make list
make -j`nproc` fetch
make -j`nproc`
if [ "$PACKAGE" = "yes" ]; then
make package
fi
else
make prebuilt
make .luac
fi
cd ../..

info "Bootstrapping"
export PKG_CONFIG_LIBDIR=$PWD/contrib/$TRIPLET/lib/pkgconfig
export PATH=$PWD/contrib/$TRIPLET/bin:$PATH
echo $PATH

./bootstrap

info "Configuring VLC"
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

../extras/package/win32/configure.sh --host=$TRIPLET $CONFIGFLAGS

info "Compiling"
make -j`nproc`

if [ "$INSTALLER" = "n" ]; then
make package-win32-debug package-win32
elif [ "$INSTALLER" = "r" ]; then
make package-win32
elif [ "$INSTALLER" = "u" ]; then
make package-win32-release
sha512sum vlc-*-release.7z
fi
