#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

CERTS_DIR="$PROJECT_DIR/certs"
CERT_FILE="$CERTS_DIR/localhost.crt"
KEY_FILE="$CERTS_DIR/localhost.key"

DAYS="${DAYS:-825}"
CN="${CN:-localhost}"
SAN="${SAN:-DNS:localhost,DNS:traefik.localhost,IP:127.0.0.1,IP:::1}"

mkdir -p "$CERTS_DIR"

if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ] && [ "${FORCE:-0}" != "1" ]; then
  echo "✔ Certificados ya existen en $CERTS_DIR (usa FORCE=1 para regenerar)"
  exit 0
fi

echo "▶ Generando clave privada RSA 4096 bits..."
openssl genrsa -out "$KEY_FILE" 4096 2>/dev/null

chmod 600 "$KEY_FILE"

echo "▶ Generando certificado autofirmado (CN=$CN, SAN=$SAN, $DAYS días)..."

SAN_ENV="subjectAltName=${SAN}"
openssl req -new -x509 \
  -key "$KEY_FILE" \
  -out "$CERT_FILE" \
  -days "$DAYS" \
  -subj "/C=PE/ST=Arequipa/L=Arequipa/O=SD-Lab/OU=Lab11/CN=$CN" \
  -addext "$SAN_ENV" \
  -addext "keyUsage=digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage=serverAuth,clientAuth" 2>/dev/null

chmod 644 "$CERT_FILE"

echo ""
echo "✔ Certificado generado:"
echo "   cert: $CERT_FILE"
echo "   key:  $KEY_FILE"
echo ""
echo "▶ Detalles del certificado:"
openssl x509 -in "$CERT_FILE" -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null
