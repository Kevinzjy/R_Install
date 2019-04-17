#!/bin/bash
set -eo pipefail

PREFIX=$HOME/R
CURRENT_DIR=$(pwd)
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)

if [[ $CURRENT_DIR != $SCRIPT_DIR ]]; then
    echo "ERROR: you must run this script under ${SCRIPT_DIR}" >&2
    exit 1
fi

echo -n "
R-3.5.1 will now be installed into this location:
$PREFIX

  - Press ENTER to confirm the location
  - Press CTRL-C to abort the installation
  - Or sepcify a different location below

[$PREFIX] >>> "

read user_prefix

if [[ $user_prefix != "" ]]; then
    case "$user_prefix" in
        *\ * )
            echo "ERROR: Cannot install into directories with spaces" >&2
            exit 1
            ;;
        *)
            eval PREFIX="$user_prefix"
            ;;
    esac
fi

if [[ -e $PREFIX ]]; then
    echo "ERROR: Directory already exists: $PREFIX" >&2
    exit 1
fi

mkdir -p $PREFIX
if (( $? )); then
    echo "ERROR: Could not create directory: $PREFIX" >&2
    exit 1
fi

PREFIX=$(cd $PREFIX; pwd)
echo "Install Destination: $PREFIX"

mkdir build
if (( $? )); then
    echo "ERROR: Could not create build directory, please delete ./build directory before installation" >&2
    exit 1
fi

cd build

# zlib
tar zxvf ../src/zlib-1.2.11.tar.gz >/dev/null
cd zlib-1.2.11
./configure --prefix=${PREFIX}
make && make install
cd ..

# bzip2
tar zxvf ../src/bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
sed -i 's/CFLAGS=/CFLAGS= -fPIC /g' Makefile # enable share lib
make && make install PREFIX=${PREFIX}
cd ..

# liblzma
tar zxvf ../src/xz-5.2.3.tar.gz
cd xz-5.2.3
./configure --prefix=${PREFIX}
make && make install
cd ..

# pcre
tar zxvf ../src/pcre-8.40.tar.gz
cd pcre-8.40
./configure --enable-utf8 prefix=${PREFIX}
make && make install
cd ..

# libcurl
tar zxvf ../src/curl-7.53.1.tar.gz
cd curl-7.53.1
./configure --prefix=${PREFIX}
make && make install
cd ..

# configure
if [ $PATH ]; then
    export PATH=${PREFIX}/bin:$PATH
else
    export PATH=${PREFIX}/bin
fi

if [ $LD_LIBRARY_PATH ]; then
    export LD_LIBRARY_PATH=${PREFIX}/include:$LD_LIBRARY_PATH
else
    export LD_LIBRARY_PATH=${PREFIX}/include
fi

export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

# R
tar zxvf ../src/R-3.5.1.tar.gz
cd R-3.5.1
./configure --prefix=${PREFIX} --enable-R-shlib
make && make install
cd $SCRIPT_DIR

echo -n "Successfully installed R-3.5.1 to $PREFIX, You may need to add following lines to your .bashrc:
export PATH=$PREFIX/bin:\$PATH
"
