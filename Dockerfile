FROM jfxs/flutter:3.47.9-001 AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
COPY src src
COPY apps apps

RUN flutter pub get

COPY . .

RUN mkdir -p /app/release && dart compile exe apps/server/bin/server.dart -o /app/release/server

FROM gcr.io/distroless/base-debian12

COPY --from=build /app/release/server /server

EXPOSE 8080

ENTRYPOINT ["/server"]
