FROM haskell as dev

ENV RESOLVER=nightly-2025-05-01 \
    LC_ALL=C.UTF-8

RUN ghc --version
RUN stack setup --resolver=$RESOLVER --install-ghc
RUN apt-get update && apt-get install -y --no-install-recommends git && apt-get clean && rm -rf /var/lib/apt/lists
WORKDIR /build
# Refresh the Hackage package index before building. The `haskell` base image
# ships a snapshot of the index that predates some deps pulled in by hledger's
# own stack.yaml (e.g. Diff-1.0.2, Decimal-0.5.2); without this refresh, Stack
# fails with "[S-922] No cryptographic hash found for Hackage package ...".
RUN stack update
# Only hledger (for `hledger close`) and hledger-web are used from this image.
# hledger-ui and the various add-ons (stockquotes, iadd, interest, and the
# Python pricehist/hledger-utils/hledger-lots tools) were dropped to slim the
# image and speed up the build.
RUN git clone --depth 1 --branch 1.43.2 https://github.com/simonmichael/hledger \
    && cd hledger \
    && stack install --jobs 4 hledger hledger-web

# Strip debug symbols from the binaries to reduce size
RUN find /root/.local/bin/ -type f -executable -exec strip --strip-unneeded {} \; 2>/dev/null || true

FROM debian:bookworm-slim

MAINTAINER Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --yes --no-install-recommends libgmp10 libtinfo6 less && apt-get clean && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger && mkdir /.cache && chmod 0777 /.cache

COPY --from=dev /root/.local/bin/hledger /usr/bin/
COPY --from=dev /root/.local/bin/hledger-web /usr/bin/

ENV LC_ALL=C.UTF-8

COPY data /data
VOLUME /data

EXPOSE 5000 5001

COPY start.sh /start.sh

USER hledger
WORKDIR /data

CMD ["/start.sh"]
