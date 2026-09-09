# sightpane dashboard, served on its own.
#
# The normal deployment does not need this: the backend serves the built
# dashboard from SIGHTPANE_UI_DIR, which keeps both on one origin. This image is
# for putting the dashboard behind its own CDN or ingress, and then
# SIGHTPANE_API_URL has to name the backend and the backend's CORS has to allow
# that origin.
FROM debian:bookworm-slim AS build
ARG FLUTTER_VERSION=3.47.0
# Empty means "same origin"; pass the backend's address when the dashboard is
# served from somewhere else.
ARG API_URL=
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" | tar -xJ -C /opt
ENV PATH="/opt/flutter/bin:${PATH}"
RUN git config --global --add safe.directory /opt/flutter && flutter config --no-analytics --enable-web && flutter precache --web
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --dart-define=SIGHTPANE_API_URL=$API_URL

FROM nginx:1.27-alpine
COPY --from=build /src/build/web /usr/share/nginx/html
# The dashboard is a single-page app: an unknown path is a client route, so it
# has to fall through to index.html instead of 404ing.
RUN printf 'server {\n  listen 80;\n  root /usr/share/nginx/html;\n  location / {\n    try_files $uri $uri/ /index.html;\n  }\n}\n' > /etc/nginx/conf.d/default.conf
EXPOSE 80
