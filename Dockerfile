# syntax=docker/dockerfile:1.6

############################
# 1) BUILD (JVM)
############################
FROM maven:3.9-eclipse-temurin-21 AS build-jvm
WORKDIR /workspace/app

# Cache deps dulu
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests dependency:go-offline

# Build fast-jar
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests package

############################
# 2) RUNTIME (JVM)
############################
FROM eclipse-temurin:21-jre AS runtime-jvm
RUN useradd -r -u 1001 quarkus && mkdir -p /work && chown -R 1001:1001 /work
WORKDIR /work
COPY --from=build-jvm /workspace/app/target/quarkus-app ./quarkus-app
USER 1001
EXPOSE 8080
ENV JAVA_OPTS="" QUARKUS_HTTP_HOST=0.0.0.0
ENTRYPOINT ["bash","-lc","java $JAVA_OPTS -jar quarkus-app/quarkus-run.jar"]

############################
# 3) BUILD (NATIVE) — Mandrel
############################
# Mandrel builder sudah include native-image ⇒ no 'gu install'
# Versi contoh: 23.1 untuk Java 21
FROM quay.io/quarkus/ubi-quarkus-mandrel-builder-image:23.1-java21 AS build-native
WORKDIR /workspace/app

# Cache deps dulu
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests dependency:go-offline

# Build native runner
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests -Pnative package

############################
# 4) RUNTIME (NATIVE)
############################
FROM quay.io/quarkus/ubi9-quarkus-micro-image:2.0 AS runtime-native
WORKDIR /work/
RUN chown 1001 /work && chmod "g+rwX" /work && chown 1001:root /work

# Salin binary native hasil Mandrel
COPY --from=build-native --chown=1001:root --chmod=0755 /workspace/app/target/*-runner /work/application

EXPOSE 8080
USER 1001
ENTRYPOINT ["./application","-Dquarkus.http.host=0.0.0.0"]
