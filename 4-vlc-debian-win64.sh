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
sed -i -e "8,12s/D3D11_VDOV_DIMENSION/D3D11_VDOV_DIMENSION7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "14,17s/D3D11_TEX2D_VDOV/D3D11_TEX2D_VDOV7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "19,28s/D3D11_VIDEO_DECODER_OUTPUT_VIEW_DESC/D3D11_VIDEO_DECODER_OUTPUT_VIEW_DESC7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "35,39s/ID3D11VideoDecoderOutputView/ID3D11VideoDecoderOutputView7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "46,48s/ID3D11VideoDecoder/ID3D11VideoDecoder7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "50,61s/D3D11_VIDEO_DECODER_BUFFER_TYPE/D3D11_VIDEO_DECODER_BUFFER_TYPE7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "63,68s/D3D11_ENCRYPTED_BLOCK_INFO/D3D11_ENCRYPTED_BLOCK_INFO7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "70,86s/D3D11_VIDEO_DECODER_BUFFER_DESC/D3D11_VIDEO_DECODER_BUFFER_DESC7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "93,114s/ID3D11VideoContext/ID3D11VideoContext7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "116,122s/D3D11_VIDEO_DECODER_DESC/D3D11_VIDEO_DECODER_DESC7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "124,143s/D3D11_VIDEO_DECODER_CONFIG/D3D11_VIDEO_DECODER_CONFIG7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "145,150s/D3D11_AUTHENTICATED_CHANNEL_TYPE/D3D11_AUTHENTICATED_CHANNEL_TYPE7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "152s/ID3D11VideoProcessorEnumerator/ID3D11VideoProcessorEnumerator7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "153s/ID3D11VideoProcessor/ID3D11VideoProcessor7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "154s/ID3D11VideoProcessorInputView/ID3D11VideoProcessorInputView7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "155s/ID3D11VideoProcessorOutputView/ID3D11VideoProcessorOutputView7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "156s/ID3D11AuthenticatedChannel/ID3D11AuthenticatedChannel7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "157s/ID3D11CryptoSession/ID3D11CryptoSession7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "164,214s/ID3D11VideoDevice/ID3D11VideoDevice7/g" /build/vlc/contrib/src/d3d11/id3d11videodecoder.patch
sed -i -e "s^FAAD2_URL :=.*$^FAAD2_URL := https://sourceforge.net/projects/faac/files/faad2-src/faad2-2.7/faad2-2.7.tar.gz^g" /build/vlc/contrib/src/faad2/rules.mak
sed -i -e "s^GNUTLS_URL :=.*$^GNUTLS_URL := https://gnupg.org/ftp/gcrypt/gnutls/v3.2/gnutls-3.2.21.tar.xz^g" /build/vlc/contrib/src/gnutls/rules.mak
sed -i -e "s^KATE_URL :=.*$^KATE_URL := http://ftp.oregonstate.edu/.1/xiph/releases/kate/libkate-0.4.1.tar.gz^g" /build/vlc/contrib/src/kate/rules.mak
sed -i -e "s^LIBMPEG2_URL :=.*$^LIBMPEG2_URL := https://ftp.osuosl.org/pub/blfs/conglomeration/libmpeg2/libmpeg2-0.5.1.tar.gz^g" /build/vlc/contrib/src/libmpeg2/rules.mak
sed -i -e "s^SAMPLERATE_URL :=.*$^SAMPLERATE_URL := http://pkgs.fedoraproject.org/repo/pkgs/libsamplerate/libsamplerate-0.1.8.tar.gz^g" /build/vlc/contrib/src/samplerate/rules.mak
sed -i -e "s^SPEEX_URL :=.*$^SPEEX_URL := https://ftp.osuosl.org/pub/xiph/releases/speex/speex-1.2rc2.tar.gz^g" /build/vlc/contrib/src/speex/rules.mak
sed -i -e "s^SPEEXDSP_URL :=.*$^SPEEXDSP_URL := https://ftp.osuosl.org/pub/xiph/releases/speex/speexdsp-1.2rc3.tar.gz^g" /build/vlc/contrib/src/speexdsp/rules.mak
sed -i -e "s^TAGLIB_URL :=.*$^TAGLIB_URL := http://pkgs.fedoraproject.org/repo/pkgs/mingw-taglib/taglib-1.9.1.tar.gz^g" /build/vlc/contrib/src/speexdsp/rules.mak
sed -i -e "s^ .sum-gpg-error^^g" /build/vlc/contrib/src/gpg-error/rules.mak
sed -i -e "s^GPGERROR_VERSION := 1.18^GPGERROR_VERSION := 1.27^g" /build/vlc/contrib/src/gpg-error/rules.mak
sed -i -e "/no-executable.patch/d" /build/vlc/contrib/src/gpg-error/rules.mak
sed -i -e "s^GLEW_URL :=.*$^GLEW_URL := https://sourceforge.net/projects/glew/files/glew/1.7.0/glew-1.7.0.tgz^g" /build/vlc/contrib/src/glew/rules.mak
sed -i -e "s^GOOM_URL :=.*$^GOOM_URL := https://sourceforge.net/projects/goom/files/goom2k4/0/goom-2k4-0-src.tar.gz^g" /build/vlc/contrib/src/goom/rules.mak
sed -i -e "s^GLEW_URL :=.*$^GLEW_URL := https://sourceforge.net/projects/glew/files/glew/1.7.0/glew-1.7.0.tgz^g" /build/vlc/contrib/src/glew/rules.mak
sed -i -e "s^MODPLUG_URL :=.*$^MODPLUG_URL := https://sourceforge.net/projects/modplug-xmms/files/libmodplug/0.8.8.5/libmodplug-0.8.8.5.tar.gz^g" /build/vlc/contrib/src/modplug/rules.mak
sed -i -e "s^MPG123_URL :=.*$^MPG123_URL := https://sourceforge.net/projects/mpg123/files/mpg123/1.21.0/mpg123-1.21.0.tar.bz2^g" /build/vlc/contrib/src/mpg123/rules.mak
sed -i -e "s^PROJECTM_URL :=.*$^PROJECTM_URL := https://sourceforge.net/projects/projectm/files/2.0.1/projectM-2.0.1-Source.tar.gz^g" /build/vlc/contrib/src/projectM/rules.mak
sed -i -e "s^SAMPLERATE_URL :=.*$^SAMPLERATE_URL := https://download.videolan.org/contrib/samplerate/libsamplerate-0.1.8.tar.gz^g" /build/vlc/contrib/src/samplerate/rules.mak
sed -i -e "s^SID_URL :=.*$^SID_URL := https://sourceforge.net/projects/sidplay2/files/sidplay2/sidplay-libs-2.1.1/sidplay-libs-2.1.1.tar.gz^g" /build/vlc/contrib/src/sidplay2/rules.mak
sed -i -e "s^ .sum-speexdsp^^g" /build/vlc/contrib/src/speexdsp/rules.mak
sed -i -e "s^TWOLAME_URL :=.*$^TWOLAME_URL := https://sourceforge.net/projects/twolame/files/twolame/0.3.13/twolame-0.3.13.tar.gz^g" /build/vlc/contrib/src/twolame/rules.mak
sed -i -e "s^UPNP_URL :=.*$^UPNP_URL := https://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%201.6.19/libupnp-1.6.19.tar.bz2^g" /build/vlc/contrib/src/upnp/rules.mak
sed -i -e "s^VNCSERVER_URL :=.*$^VNCSERVER_URL := https://sourceforge.net/projects/libvncserver/files/libvncserver/0.9.9/LibVNCServer-0.9.9.tar.gz^g" /build/vlc/contrib/src/vncserver/rules.mak
sed -i -e "s^--enable-static^--enable-static --disable-asm^g" /build/vlc/contrib/src/x264/rules.mak

echo "Building extra tools"
cd extras/tools
./bootstrap
make -j`nproc`
PATH=$PWD/build/bin:$PATH
cd ../../

echo "Building contribs"
export USE_FFMPEG=1
mkdir -p contrib/contrib-$SHORTARCH && cd contrib/contrib-$SHORTARCH
if [ ! -z "$BREAKPAD" ]; then
     CONTRIBFLAGS="$CONTRIBFLAGS --enable-breakpad"
fi
#../bootstrap --host=$TARGET_TUPLE  --disable-qt --disable-skins2 --disable-lua --disable-protobuf --disable-gettext
../bootstrap --host=$TARGET_TUPLE --disable-cddb --disable-crystalhd --disable-gme --disable-ssh2 --disable-projectM --disable-qt --disable-x265

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
make -j`nproc`

if [ "$INSTALLER" = "n" ]; then
make package-win32-debug package-win32
elif [ "$INSTALLER" = "r" ]; then
make package-win32
elif [ "$INSTALLER" = "u" ]; then
make package-win32-release
sha512sum vlc-*-release.7z
fi
