FROM ghcr.io/loong64/alpine:3.21 AS builder

RUN apk add --no-cache \
        bash \
        bison \
        bzip2 \
        ccache \
        curl \
        coreutils \
        diffutils \
        file \
        flex \
        g++ \
        gcc \
        git \
        libarchive-tools \
        make \
        musl-dev \
        patch \
        perl \
        rsync \
        texinfo \
        xz \
        zip

RUN addgroup -g 1000 builder && \
    adduser -u 1000 -h /builder -D -G builder -s /bin/bash builder && \
    mkdir -p /dist && chown -R builder:builder /dist

USER builder

WORKDIR /tmp/musl-cross-make
COPY . .

# MUSL_TARGET: loongarch64-linux-musl
ARG MUSL_TARGET

RUN export TARGET=${MUSL_TARGET} \
    && ./scripts/build ${MUSL_TARGET} \
    && mv output/*.tgz /dist/

FROM scratch
COPY --from=builder /dist/ /dist/