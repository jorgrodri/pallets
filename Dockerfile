FROM node:20-slim AS build

WORKDIR /app

# Copia los archivos de dependencias y el resto del código
COPY package.json ./
COPY bun.lock ./
COPY . .

# Instala dependencias y compila usando Node
RUN npm install && npm run build

# --- Etapa final: Servir con Bun ---
FROM oven/bun:1.0-slim
WORKDIR /app
COPY --from=build /app .

# Instala solo las dependencias de producción con Bun (opcional, si usas bun para servir)
RUN bun install --production

# Expone el puerto por defecto (ajusta si usas otro)
EXPOSE 4000

# Comando de arranque para Dokploys usando Bun
CMD ["bun", "run", "serve:ssr:pallet"]
