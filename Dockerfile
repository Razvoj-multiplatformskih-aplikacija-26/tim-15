FROM dart:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
COPY src src
COPY apps apps

RUN dart pub get

COPY . .

RUN dart compile exe apps/server/bin/server.dart -o /app/release/server

FROM gcr.io/distroless/base-debian12

COPY --from=build /app/release/server /server

EXPOSE 8080

ENTRYPOINT ["/server"]
