# syntax=docker/dockerfile:1.6

############################
# 1) BUILD (JVM)
############################
FROM maven:3.9-eclipse-temurin-21 AS build-jvm
WORKDIR /workspace/app

# Copy pom lebih dulu untuk memaksimalkan cache dependensi
COPY pom.xml .
# Gunakan cache untuk ~/.m2 saat mvn resolve
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests dependency:go-offline

# Copy source dan build fast-jar
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests package

############################
# 2) RUNTIME (JVM)
############################
FROM eclipse-temurin:21-jre AS runtime-jvm
# Pilih user non-root yang aman
RUN useradd -r -u 1001 quarkus && mkdir -p /work && chown -R 1001:1001 /work
WORKDIR /work

# Struktur fast-jar: target/quarkus-app/*
COPY --from=build-jvm /workspace/app/target/quarkus-app ./quarkus-app
USER 1001

EXPOSE 8080
ENV JAVA_OPTS="" \
    QUARKUS_HTTP_HOST=0.0.0.0
# Entry untuk fast-jar
ENTRYPOINT ["bash","-lc","java $JAVA_OPTS -jar quarkus-app/quarkus-run.jar"]

############################
# 3) BUILD (NATIVE)
############################
# Image GraalVM Community untuk build native-image (Java 21)
FROM ghcr.io/graalvm/graalvm-community:21 AS build-native
RUN gu install native-image
WORKDIR /workspace/app

COPY pom.xml .
# Cache dependensi terlebih dulu
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests dependency:go-offline

COPY src ./src
# Profile native -> menghasilkan target/*-runner
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests -Pnative package

############################
# 4) RUNTIME (NATIVE)
############################
# Base micro image Quarkus untuk binary native
FROM quay.io/quarkus/ubi9-quarkus-micro-image:2.0 AS runtime-native
WORKDIR /work/
RUN chown 1001 /work \
  && chmod "g+rwX" /work \
  && chown 1001:root /work

# Salin binary native
COPY --from=build-native --chown=1001:root --chmod=0755 /workspace/app/target/*-runner /work/application

EXPOSE 8080
USER 1001
# Jalankan sebagai binary native
ENTRYPOINT ["./application", "-Dquarkus.http.host=0.0.0.0"]
