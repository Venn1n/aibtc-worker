# Stage 1: Build
FROM rust:1.78-slim as builder

WORKDIR /app

# Install dependencies untuk build
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy source
COPY Cargo.toml ./
COPY src ./src

# Build release
RUN cargo build --release

# Stage 2: Runtime (image kecil)
FROM debian:bookworm-slim

WORKDIR /app

# Install SSL runtime
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Copy binary dari builder
COPY --from=builder /app/target/release/aibtc-rust .

# Jalankan dengan ENV variable WALLET_ADDRESS
CMD ["sh", "-c", "./aibtc-rust ${WALLET_ADDRESS}"]
