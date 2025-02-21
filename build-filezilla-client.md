# Cross-compile FileZilla Client 3.65.x on Windows Subsystem for Linux (WSL1)
  
Guide is based on FileZilla at v3.65.0 and libfilezilla v0.44 (r40) in the SVN - all attempts will be made to keep guide relatively current.  Some dependencies are version specific based on the SVN revision of FileZilla and libfilezilla - recommended to follow versions as noted.  

* **REQUIRES** Windows 10 r1607 or higher
* The filezilla-project recommends Debian 11 (bullseye) for cross-compile so it will be used here.  
* All parts of this guide assume that your Program Files (x86) folder is located on drive C:  
 You may need to adjust certain paths in these guides as needed to accomodate differences.
* **RECOMMENDED** (but not required) to install a clean WSL userspace for this process.  
  * Importing a clean userspace into WSL defaults that userspace to the root user.  This means ```sudo``` and other permissions requirements are generally not encountered.  
  * A TL;DR guide to installing a clean WSL userspace [can be found here](https://gist.github.com/iam-sysop/f2987d6873d370fc47d1279b2a0d0fcc).  
* This guide assumes you have knowledge of linux permissions and usage of sudo elevation as necessary.

<br>

## Prepare Build Environment

(in Windows) Download and install NSIS from SourceForge  
https://sourceforge.net/projects/nsis/files/NSIS%203/3.09/nsis-3.09-setup.exe/download
<br><br>

### **Launch WSL**  
  
Add 32bit architecture for compiling Windows shell extension:  
```shell
dpkg --add-architecture i386
```

**RECOMMENDED**: Update the userspace prior to proceeding.  
```shell
apt-get update
apt-get upgrade
```

Install required packages:
```shell
apt-get install wget git subversion \
    gettext lzip automake autoconf autogen autopoint \
    libtool make pkg-config wx-common \
    mingw-w64 mingw-w64-tools
```

Install optional `colormake` package (better visibility of any compile errors):
```shell
apt-get install colormake
```

Setup some paths:  
```shell
mkdir /sources && mkdir /builds && mkdir /builds/filezilla && mkdir /builds/filezilla/client64
```

Configure environment variables  
> *optional*: download helper script via wget from [here](
https://raw.githubusercontent.com/iam-sysop/make-filezilla/main/scripts/setenv-buildfz ) to /sources folder and execute via `. /sources/setenv-buildfz client64`  
```shell
export TPFX="/builds/filezilla/client64"
export THOST="x86_64-w64-mingw32"
export TBLD="x86_64-pc-linux"
export PATH="$TPFX/bin:$PATH"
export CPPFLAGS="-I$TPFX/include"
export LDFLAGS="-L$TPFX/lib"
export LD_LIBRARY_PATH="-L$TPFX/lib"
export PKG_CONFIG_PATH="$TPFX/lib/pkgconfig:$PKG_CONFIG_PATH"
```

<br>

## Download/Unpack Sources
> Change to `/sources` folder before continuing.



### Dependencies


**GMP**
```shell
wget https://gmplib.org/download/gmp/gmp-6.3.0.tar.lz
tar xvf gmp-6.3.0.tar.lz
```

**Nettle**
```shell
wget https://ftp.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz
tar xvf nettle-3.9.1.tar.gz
```

**zlib**
```shell
wget http://zlib.net/zlib-1.3.tar.gz
tar xf zlib-1.3.tar.gz
```

**gnuTLS**
```shell
wget https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.1.tar.xz
tar xvf gnutls-3.8.1.tar.xz
```

**sqlite**
```shell
wget https://www.sqlite.org/2023/sqlite-autoconf-3430000.tar.gz
tar xvf sqlite-autoconf-3430000.tar.gz
```

**wxWidgets**  
(latest 3.2 branch stable):
```shell
wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.2.1/wxWidgets-3.2.2.1.tar.bz2
tar xjvf wxWidgets-3.2.2.1.tar.bz2
mv wxWidgets-3.2.2.1 wxWidgets-3.2.x
```

(latest 3.2 branch development):
```shell
git clone --branch 3.2 --single-branch https://github.com/wxWidgets/wxWidgets.git wxWidgets-3.2.x
```

**libfilezilla**  
(latest stable - 0.44.0 as of this guide against FileZilla v3.65.0):  
```shell
svn co -r 10987 https://svn.filezilla-project.org/svn/libfilezilla/trunk libfilezilla
```
(latest development):  
```shell
svn co https://svn.filezilla-project.org/svn/libfilezilla/trunk libfilezilla
```

**FileZilla**  
(latest stable - 3.65.0 as of this guide against libfilezilla 0.44):  
```shell
svn co -r 10997 https://svn.filezilla-project.org/svn/FileZilla3/trunk filezilla
```
(latest development):  
```shell
svn co https://svn.filezilla-project.org/svn/FileZilla3/trunk filezilla
```

<br>

## Build Dependencies
> Most modern hardware is multi-core enabled.  When running `make` parallel builds can speed up compilation. All `make` commands below assume usage of a parallel build via `-jN` parameter where `N` = totalCoresAvailable - 1.  
> Example (quad core): `make -j3`.
>
> Change to `/sources` folder before continuing.


**COMPILE GMP**
```shell
cd gmp-6.3.0

CC_FOR_BUILD=gcc ./configure --host=$THOST --prefix="$TPFX" --disable-static --enable-shared --enable-fat CFLAGS="-Wno-attributes"

make -jN && make install

cd ..
```
**COMPILE NETTLE**
```shell
cd nettle-3.9.1

./configure --host=$THOST --prefix="$TPFX" --enable-shared --disable-static --enable-fat 

make -jN && make install

cd ..
```
**COMPILE ZLIB**
```shell
cd zlib-1.3

CHOST=$THOST SHAREDLIB=zlib1.dll IMPLIB=zlib1.dll.a ./configure --prefix="$TPFX" 

make -jN && make install

cd ..
```
**COMPILE GNUTLS**
```shell
cd gnutls-3.8.1

autoreconf -f -i

./configure \
--build=$TBLD \
--host=$THOST \
--prefix="$TPFX" \
--enable-shared \
--disable-static \
--without-p11-kit \
--with-included-libtasn1 \
--with-included-unistring \
--enable-local-libopts \
--disable-srp-authentication \
--disable-dtls-srtp-support \
--disable-heartbeat-support \
--disable-psk-authentication \
--disable-anon-authentication \
--disable-openssl-compatibility \
--without-tpm \
--without-brotli \
--disable-cxx \
--disable-guile \
--disable-doc \
--disable-maintainer-mode \
--disable-libdane \
--enable-threads=windows \
--disable-tools \
ARFLAGS="cr" \
CFLAGS="-Wno-unused-function -Wno-unused-variable -Wno-unused-macros"

make -jN && make install

cd ..
```
**COMPILE SQLITE**
```shell
cd sqlite-autoconf-3430000

./configure --host=$THOST --prefix="$TPFX" --enable-shared --disable-static --disable-dynamic-extensions LDFLAGS=

make -jN && make install

cd ..
```
**COMPILE WXWIDGETS**  
```shell
cd wxWidgets-3.2.x

./configure --host=$THOST --build=$TBLD --prefix="$TPFX" --enable-shared --disable-gtktest --disable-sdltest --enable-vendor=mingw32 --disable-compat28

make -jN && make install

cd ..
```
**COMPILE LIBFILEZILLA**  
>As of v0.33 (r20) of libfilezilla, a compile error exists on MinGW due to libuuid not truly being an import library with libtool. It needs to be pulled in via gcc differently to successfully build.  A .patch file is [available here](https://raw.githubusercontent.com/iam-sysop/make-filezilla/main/patches/patch-libfilezilla-0.32-0.33.x-mingw-uuid.patch) and must be applied before `autoreconf`.  Visual here: https://github.com/thecarnie/make-filezilla/blob/main/patches/patch-libfilezilla-0.32-0.33.x-mingw-uuid.patch  
>No patch is needed for v0.34.0 and above.  
```shell
cd libfilezilla

autoreconf -f -i
./configure --host=$THOST --build=$TBLD --prefix="$TPFX" --enable-shared --disable-static ARFLAGS=cr

make -jN && make install

cd ..
```
## **COMPILE FILEZILLA**  
> Under WSL, path issues cause GCC's objdump to pull in too many DLLs for export.  A .patch file is [available here](https://raw.githubusercontent.com/iam-sysop/make-filezilla/main/patches/patch-filezilla-Makefile.am.patch) that resolves this issue against v3.55.1 and up of the code so that DLLs are properly dumped for linking, as well as collecting for the installer package. Patch must be applied before `autoreconf`. **WARNING**: verify patch against local file before applying - updates to filezilla source may affect patch. Visual here: https://github.com/thecarnie/make-filezilla/blob/main/patches/patch-filezilla-Makefile.am.patch  
> 
> If you wish to make use of precompiled headers, the following patch is required to overcome MinGW GCC-10 dumpversion output readible by `configure`.  A .patch file is [available here](https://raw.githubusercontent.com/iam-sysop/make-filezilla/main/patches/patch-filezilla-configure.ac-mingw-pch.patch) that resolves this issue and allows `configure` to properly detect a valid compiler and use precompiled headers. Patch must be applied before `autoreconf`. **WARNING**: verify patch against local file before applying - updates to filezilla source may affect patch. Visual here: https://github.com/thecarnie/make-filezilla/blob/main/patches/patch-filezilla-configure.ac-mingw-pch.patch
```shell
cd filezilla

autoreconf -f -i
./configure --host=$THOST --build=$TBLD --prefix="$TPFX" --enable-shared --disable-static --with-pugixml=builtin --with-wx-config="$TPFX/bin/wx-config"

make -jN
```
> If you get an error about missing Boost Regex required, run the steps below, then go back and re-run FileZilla configure and make steps.
```shell
apt-get install build-essential
wget https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.bz2
tar xjvf boost_1_83_0.tar.bz2
cd boost_1_83_0
echo "using gcc :  : x86_64-w64-mingw32-g++ ;" > user-config.jam
./bootstrap.sh
./b2 --user-config=./user-config.jam --with-regex --prefix=$TPFX target-os=windows address-model=64 variant=release install
```

The FileZilla.exe should now be compiled.  The following commands will cleanup debug symbols and package the installer.
> *optional*: download helper script via wget from [here](https://raw.githubusercontent.com/iam-sysop/make-filezilla/main/scripts/package-fzclient ) to /sources folder and execute via `. /sources/package-fz-installer` 
```shell
$THOST-strip /sources/filezilla/src/interface/.libs/filezilla.exe
$THOST-strip /sources/filezilla/src/putty/.libs/*.exe
$THOST-strip /sources/filezilla/src/fzshellext/64/.libs/libfzshellext-0.dll
$THOST-strip /sources/filezilla/src/fzshellext/32/.libs/libfzshellext-0.dll
$THOST-strip /sources/filezilla/data/dlls_gui/*.dll

cd /sources/filezilla/data
"/mnt/c/Program Files (x86)/NSIS/makensis.exe" install.nsi

cp FileZilla_3*_setup.exe $TPFX/..

cd $TPFX/..
```
<br>

---

**There should now be a FileZilla_3_setup.exe file available in the /builds/filezilla folder ready for installation on Windows.**  

![FileZilla Client 3.65.0 via WSL build](https://github.com/iam-sysop/make-filezilla/blob/main/filezilla-3.65.0-wsl.png)
