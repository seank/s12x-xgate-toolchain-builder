#!/bin/bash

#TODO add config vars for things like debug-syms, install dir, offline mode

set -e


########## get and or update necessary repositories ###########
if [ ! -d FreeScale-s12x-binutils ]
then
	echo "Cloning binutils repository"
	git clone git://github.com/seank/FreeScale-s12x-binutils.git
else 
	echo "Updating binutils repository"
	cd FreeScale-s12x-binutils
	git pull
	cd ..  	 
fi


if [ ! -d FreeScale-s12x-gcc ]
then
	echo "Cloning gcc repository"
	git clone git://github.com/seank/FreeScale-s12x-gcc.git
else 
	echo "Updating gcc repository"
	cd FreeScale-s12x-gcc
	git pull
	cd ..  	 
fi


if [ ! -d FreeScale-s12x-newlib ]
then
	echo "Cloning newlib repository"
	git clone git://github.com/seank/FreeScale-s12x-newlib.git
else 
	echo "Updating newlib repository"
	cd FreeScale-s12x-newlib
	git pull
	cd ..  	 
fi

########## build binutils for xgate #############
INSTALLDIR=/usr/local
if [ ! -d xgateBinutils-build ]
then 
	mkdir xgateBinutils-build
	cd xgateBinutils-build
	../FreeScale-s12x-binutils/configure --target=xgate \
			--enable-targets=xgate \
			--program-prefix=xgate- \
			--prefix=/usr/local 
else	
	cd xgateBinutils-build
fi
		
make
sudo make install
cd ..

########## build binutils for s12x #############
INSTALLDIR=/usr/local
if [ ! -d s12xBinutils-build ]
then 
	mkdir s12xBinutils-build
	cd s12xBinutils-build
	../FreeScale-s12x-binutils/configure --target=m68hc11 \
			--enable-targets=m68hc11,m68hc12,xgate \
			--program-prefix=m68hc11- \
			--prefix=/usr/local 
else	
	cd s12xBinutils-build
fi
		
make
sudo make install
cd ..

###### Keep old gcc port happy by adding binutils links ##########
###### Change hardlinks to symlinks ############
sudo bash -c 'for i in ar as ld nm objcopy objdump ranlib strip
do 
        rm  -f /usr/local/xgate/bin/$i 
        ln -s /usr/local/bin/xgate-$i /usr/local/xgate/bin/$i ; 
        rm -f /usr/local/m68hc11/bin/$i 
        ln -s /usr/local/bin/m68hc11-$i /usr/local/m68hc11/bin/$i ; 
done'


########### build and install gcc ############################

INSTALLDIR=/usr/local
if [ ! -d gcc-build ]
then 
	mkdir gcc-build
	cd gcc-build
	../FreeScale-s12x-gcc/src/configure --program-prefix=m68hc11- \
			     --enable-languages=c \
			     --target=m68hc11 \
			     --with-gnu-as \
			     --with-gnu-ld \
			     --enable-nls \
			     --without-included-gettext \
			     --disable-checking \
			     --without-headers  \
			     --prefix=/usr/local
#			     --disable-werror
else	
	cd gcc-build
fi
		
make
sudo make install-gcc
cd ..

########### build and install newlib ############################

INSTALLDIR=/usr/local
if [ ! -d newlib-build ]
then 
	mkdir newlib-build
	cd newlib-build
	../FreeScale-s12x-newlib/src/configure \
			     --program-prefix=m68hc11- \
			     --enable-languages=c \
			     --target=m68hc11 \
			     --with-gnu-as \
			     --with-gnu-ld \
			     --enable-nls \
			     --without-included-gettext \
			     --disable-checking \
			     --without-headers  \
			     --prefix=/usr/local
#			     --disable-werror
else	
	cd newlib-build
fi
		
make
sudo make install

echo "Tool chain build sucessful, enjoy"

exit 1


mkdir newlib-build
cd newlib-build
make distclean
make clean

../../newlib-9hcs12x/newlib-repo/src/configure \
			    --host=i686-pc-linux \
			    --target=m68hc11 \
			    --program-prefix=m68hc11- \
			    --disable-shared \
			    --disable-multilib \
			    --disable-threads \
			    --disable-nls \
			    CC=m68hc11-gcc \
			    CFLAGS='-g -O2 -U_FORTIFY_SOURCE'
make
sudo make install
