FROM alpine:3.18.2

RUN set -x \
 && mkdir -p /srv/saslauthd.d /tmp/cyrus-sasl /var/run/saslauthd \
 && export BUILD_DEPS=" \
        autoconf \
        automake \
        curl \
        db-dev \
        g++ \
        gcc \
        gzip \
        heimdal-dev \
        libtool \
        make \
        openldap-dev \
        openssl-dev \
        tar \
    " \
 && apk add --update ${BUILD_DEPS} \
        cyrus-sasl \
        libldap

WORKDIR /app
COPY . .
RUN autoreconf -i && ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-anon \
        --enable-cram \
        --enable-digest \
        --enable-ldapdb \
        --enable-login \
        --enable-ntlm \
        --disable-otp \
        --enable-plain \
        --with-gss_impl=heimdal \
        --with-devrandom=/dev/urandom \
        --with-ldap=/usr \
        --with-saslauthd=/var/run/saslauthd \
        --mandir=/usr/share/man \
        && make DEBUG=1 -j1 \
        && make -j1 install

VOLUME ["/var/run/saslauthd"]

ENTRYPOINT ["/usr/sbin/saslauthd"]
CMD ["-V","-a","shadow","-d","1"]
