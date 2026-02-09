# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_ROOT=/go/prometheus \
      BUILD_SRC=prometheus/prometheus.git
  ARG BUILD_BIN=${BUILD_ROOT}/prometheus

# :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:localhealth AS distroless-localhealth
  FROM 11notes/util AS util

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: PROMETHEUS
  FROM 11notes/go:1.25 AS build
  ARG APP_VERSION \
      BUILD_SRC \
      BUILD_ROOT \
      BUILD_BIN

  RUN set -ex; \
    apk --update --no-cache add \
      g++ \
      make \
      bash \
      nodejs \
      npm;

  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    make build;

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

# :: ENTRYPOINT
  FROM 11notes/go:1.25 AS entrypoint
  COPY ./build /
  
  RUN set -ex; \
    cd /go/entrypoint; \
    eleven go build entrypoint main.go; \
    eleven distroless entrypoint;


# :: FILE SYSTEM
  FROM alpine AS file-system
  COPY --from=util / /
  ARG APP_ROOT
  USER root

  RUN set -ex; \
    eleven mkdir /distroless${APP_ROOT}/{etc,var};


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-localhealth / /
    COPY --from=build /distroless/ /
    COPY --from=entrypoint /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:3000/"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/entrypoint"]