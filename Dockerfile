FROM oven/bun:1.0 AS base

WORKDIR /app

# Instala herramientas necesarias para node-gyp y dependencias nativas
RUN apk add --no-cache python3 make g++

# Copia los archivos de dependencias y el resto del código
COPY package.json ./
COPY bun.lock ./
COPY . .

# Instala dependencias con Bun
RUN bun install

# Compila la aplicación Angular
RUN bun run build

# --- Etapa final: Arranque para Dokploys ---
FROM oven/bun:1.0-slim
WORKDIR /app
COPY --from=base /app .

# Expone el puerto por defecto (ajusta si usas otro)
EXPOSE 4000

# Comando de arranque para Dokploys usando Bun
CMD ["bun", "run", "serve:ssr:pallet"]
