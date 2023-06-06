FROM alpine:latest
RUN apk update --no-cache && apk upgrade --no-cache -l

# Snort required pkg
RUN apk add --no-cache cmake libdnet-dev hwloc-dev luajit-dev openssl-dev libpcap-dev pcre-dev zlib-dev flex-dev pkgconfig libc-dev bison git
# Build required pkg
RUN apk add --no-cache autoconf automake libtool build-base libmnl-dev
# Optional snort pkg
RUN apk add --no-cache libtirpc-dev flatbuffers-dev libunwind-dev xz-dev cpputest jemalloc-dev w3m 
# Optional libdaq pkg
RUN apk add --no-cache libnfnetlink-dev libnetfilter_queue-dev
# Hyperscan required pkg
RUN apk add --no-cache boost-dev ragel sqlite-dev binutils-dev

# Change to local time zone for better logging
RUN apk add tzdata --no-cache && cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime && echo "Asia/Seoul" > /etc/timezone && date

WORKDIR '/root'
RUN wget https://www.snort.org/downloads/snortplus/libdaq-3.0.11.tar.gz \ 
https://www.snort.org/downloads/snortplus/snort3-3.1.62.0.tar.gz \
https://github.com/rurban/safeclib/releases/download/v3.7.1/safeclib-3.7.1.tar.xz \
https://github.com/intel/hyperscan/archive/refs/tags/v5.4.2.tar.gz \
https://github.com/snort3/snort3_extra/archive/refs/tags/3.1.62.0.tar.gz

# Decompress tarball and remove files
RUN for file in *.tar.*; do tar -axf "$file"; done && for file in *.tar.*; do rm -rf "$file"; done

# safeclib
RUN cd safeclib-3.7.1 && autoreconf -ivf && ./configure && make -j$(nproc) && make install -j$(nproc) && make clean && cd ..

# hyperscan
RUN cd hyperscan-5.4.2 && cmake . && make -j$(nproc) && make install -j$(nproc) && make clean && cd ..

# libdaq
RUN cd libdaq-3.0.11 && autoreconf -ivf && ./configure && make -j$(nproc) && make install -j$(nproc) && make clean && cd ..
RUN ldconfig; exit 0

# snort
RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH && export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH && cd snort3-3.1.62.0 && ./configure_cmake.sh --prefix=/usr/local --enable-jemalloc --disable-docs && cd build && make -j$(nproc) && make install -j$(nproc) && alias snort='/usr/local/snort/bin/snort' && make clean && cd ~

# snort extra
RUN export PKG_CONFIG_PATH=/usr/local/snort/lib64/pkgconfig:$PKG_CONFIG_PATH && cd snort3_extra-3.1.62.0 &&  ./configure_cmake.sh --prefix=/usr/local && cd build && make -j$(nproc) && make install -j$(nproc) && make clean && cd ~

RUN mkdir /usr/local/etc/rules /usr/local/etc/so_rules/ /usr/local/etc/lists/ /var/log/snort
RUN touch /usr/local/etc/rules/local.rules /usr/local/etc/lists/default.blocklist

# PulledPork3
RUN git clone https://github.com/shirkdog/pulledpork3.git && apk add --no-cache py3-requests && cd pulledpork3 && mkdir /usr/local/bin/pulledpork3 && cp pulledpork.py /usr/local/bin/pulledpork3 &&  cp -r lib/ /usr/local/bin/pulledpork3 && chmod +x /usr/local/bin/pulledpork3/pulledpork.py && mkdir /usr/local/etc/pulledpork3 && cp etc/pulledpork.conf /usr/local/etc/pulledpork3/

# Recommended to run Snort3 using Snort user but for inline we should use root user
RUN addgroup -S snort && adduser -S snort -D -H -G snort && chmod -R 5775 /var/log/snort && chown -R snort:snort /var/log/snort

# Download OpenAppID
RUN wget -O ./openappid.tar.gz https://www.snort.org/downloads/openappid/26425 && tar -xzf openappid.tar.gz && cp -R odp /usr/local/lib/ && rm -rf ./openappid.tar.gz

COPY ./pulledpork.conf /usr/local/etc/pulledpork3/
COPY ./snort.lua /usr/local/etc/snort/

COPY ./startup.sh ./pulledpork.txt ./

RUN /usr/local/bin/pulledpork3/pulledpork.py -c /usr/local/etc/pulledpork3/pulledpork.conf
RUN crontab ~/pulledpork.txt && chmod +x ~/startup.sh

CMD [ "./startup.sh" ]
# CMD ["/bin/sh"]