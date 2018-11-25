from alpine:3.8 as build

run apk add --update alpine-sdk

env V      2.0.2
env SHA512 aef96f246484a52269b44963df033ccc584e62d50d1ae31a97a97b9c7375e576d70d00f61a0f6da336e60cefc4c921945df0cc821d5fd1c737b19f508e65d30b

run curl -o bird.tar.gz ftp://bird.network.cz/pub/bird/bird-${V}.tar.gz
run echo "${SHA512}  bird.tar.gz" >sha512.sum \
 && cat sha512.sum \
 && sha512sum -c sha512.sum
run tar zxvf bird.tar.gz

workdir /bird-${V}

run apk add --update bison flex ncurses-dev readline-dev linux-headers

run CFLAGS="-Os" ./configure --prefix=/usr --sysconfdir=/etc/bird --localstatedir=/var

# fix tests
add fix-tests.patch /
run patch -p1 </fix-tests.patch

# build
run make -j4
run make test
run make DESTDIR=/build install
run rm -fr /build/usr/share/man

run echo "DESTDIR contains:" \
 && cd /build && find

from alpine:3.8

run apk add --update ncurses readline

entrypoint ["/usr/sbin/bird","-f"]
copy --from=build /build /
