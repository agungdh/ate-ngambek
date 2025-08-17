# --- Stage 1: Build native image with GraalVM CE (open-source) ---
FROM ghcr.io/graalvm/native-image-community:21 AS builder
WORKDIR /workspace

# 1. Salin Maven Wrapper dan pom.xml
COPY mvnw pom.xml ./
COPY .mvn/ .mvn/

# 2. Unduh dependensi secara offline
RUN chmod +x mvnw && \
    ./mvnw dependency:go-offline -B

# 3. Salin kode sumber dan build native image
COPY src/ src/
# Profile 'native' sudah terkonfigurasi di pom.xml untuk Spring AOT
RUN ./mvnw -Pnative native:compile -DskipTests -Dspring.native.mode=compatibility

# --- Stage 2: Runtime with Debian Trixie-slim (glibc) ---
FROM debian:trixie-slim AS runtime

# Install minimal dependencies and CA certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Salin binary hasil build (pastikan nama sesuai <finalName> atau artifactId di pom.xml)
COPY --from=builder /workspace/target/ate-ngambek ./

# Jalankan aplikasi
ENTRYPOINT ["./ate-ngambek"]