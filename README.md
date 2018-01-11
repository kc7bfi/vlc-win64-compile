# vlc-win64-compile
Recipe to compile VLC for Windows 64-bit

This project vame about as an attempt to develop and share some scripts to build the 64-bit version of VLC for Windows 10. These scripts are based upon the [VLC docker images](https://code.videolan.org/videolan/docker-images).

To use these scripts:

1. Start with a fresh install of Debian Stretch.
2. Glone these scripts into the user's home directory.
3. cd to the git directory
4. su to the root user to execute the scripts
5. ./1-videolan-base-stretch.sh - this will install some needed software onto the system.
6. ./2-vlc-debian-win64.sh - this will build the tool chain
7. ./3-medialibrary-w64.sh - this will compile VLC.