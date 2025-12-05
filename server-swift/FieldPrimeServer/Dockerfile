FROM --platform=$TARGETPLATFORM swift:6.1-jammy
WORKDIR /usr/src/app
ARG SQLITE_AUTOCONF=3450000
ARG SQLITE_YEAR=2024
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential pkg-config ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL -o sqlite.tar.gz https://www.sqlite.org/${SQLITE_YEAR}/sqlite-autoconf-${SQLITE_AUTOCONF}.tar.gz \
 && tar xzf sqlite.tar.gz \
 && cd sqlite-autoconf-${SQLITE_AUTOCONF} \
 && CFLAGS="-O2 -fPIC -DSQLITE_ENABLE_SNAPSHOT -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_PREUPDATE_HOOK -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_RTREE" ./configure --prefix=/usr/local \
 && make -j"$(nproc)" \
 && make install \
 && ldconfig \
 && cd .. \
 && rm -rf sqlite-autoconf-${SQLITE_AUTOCONF} sqlite.tar.gz
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
CMD ["bash"]
