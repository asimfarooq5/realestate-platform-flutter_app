# Build stage — compile the Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.32.2 AS build

WORKDIR /app

# Copy pubspec and resolve deps first (better layer caching)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source and web assets
COPY lib/ lib/
COPY web/ web/
COPY assets/ assets/

# Build with the API base URL passed at build time
ARG API_BASE_URL=http://localhost:8000
RUN flutter build web --dart-define=API_BASE_URL=${API_BASE_URL}

# Serve stage — nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY web/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
