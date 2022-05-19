FROM ubuntu:16.04

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y build-essential git alien flex libz-dev wget initramfs-tools    

RUN cd /tmp && \
wget --no-check-certificate https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.11/linux-headers-4.10.11-041011-generic_4.10.11-041011.201704180310_amd64.deb && \
wget --no-check-certificate https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.11/linux-headers-4.10.11-041011_4.10.11-041011.201704180310_all.deb && \
wget --no-check-certificate https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.10.11/linux-image-4.10.11-041011-generic_4.10.11-041011.201704180310_amd64.deb && \
dpkg -i *.deb   

RUN cd /opt && \
git clone https://github.com/luginbash/mpss-modules.git && \
cd mpss-modules && \
sed -i '/KERNEL_VERSION := $(shell uname -r)/c\KERNEL_VERSION=4.10.11-041011-generic' Makefile && \
make MIC_CARD_ARCH=k1om && \
make install

RUN cd /tmp && \
wget http://registrationcenter-download.intel.com/akdlm/irc_nas/15904/mpss-3.8.6-linux.tar && \
tar -xf mpss-3.8.6-linux.tar && \
cd mpss-3.8.6/ && \
alien --scripts *.rpm && \
dpkg -i *.deb && \
sh -c "echo /usr/lib64 >> /etc/ld.so.conf.d/zz_x86_64-compat.conf" && \
ldconfig

RUN git clone https://github.com/apc-llc/gcc-5.1.1-knc.git && \
cd gcc-5.1.1-knc/ && \
./contrib/download_prerequisites && \
sed -i '/UNSUPPORTED=1/c\' libcilkrts/configure.tgt && \
mkdir build && \
cd build && \
export PATH=/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/:$PATH && \
ln -s /opt/mpss/3.8.6/sysroots/k1om-mpss-linux/usr/lib64 /opt/mpss/3.8.6/sysroots/k1om-mpss-linux/usr/lib && \
../configure --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=k1om-mpss-linux --prefix=$(pwd)/../install --disable-silent-rules --disable-dependency-tracking --with-ld=/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-ld --with-as=/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/k1om-mpss-linux-as --enable-shared --enable-languages=c,c++,fortran --enable-threads=posix --disable-multilib --enable-c99 --enable-long-long --enable-symvers=gnu --enable-libstdcxx-pch --program-prefix=k1om-mpss-linux- --enable-target-optspace --enable-lto --disable-bootstrap --with-system-zlib --with-linker-hash-style=gnu --enable-cheaders=c_global --with-local-prefix=/opt/mpss/3.8.6/sysroots/k1om-mpss-linux/usr --with-sysroot=/opt/mpss/3.8.6/sysroots/k1om-mpss-linux/ --disable-libunwind-exceptions --disable-libssp --disable-libgomp --disable-libmudflap --enable-nls --enable-__cxa_atexit --disable-libitm && \
make && \
make install && \
cp -r /gcc-5.1.1-knc/install/* /opt/mpss/3.8.6/sysroots/k1om-mpss-linux

RUN ln -s /opt/mpss/3.8.6/sysroots/k1om-mpss-linux/bin/k1om-mpss-linux-gcc /bin/k1om-mpss-linux-cilk-gcc && \
ln -s /opt/mpss/3.8.6/sysroots/k1om-mpss-linux/bin/k1om-mpss-linux-g++ /bin/k1om-mpss-linux-cilk-g++ && \
echo "export PATH=/opt/mpss/3.8.6/sysroots/x86_64-mpsssdk-linux/usr/bin/k1om-mpss-linux/:$PATH" >> ~/.bashrc
