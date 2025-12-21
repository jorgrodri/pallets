# Usamos Node para el Build porque el CLI de Angular 
# tiene dependencias nativas que a veces fallan con Bun en el prerendering
FROM node:20-alpine AS build

WORKDIR /app

# Instalamos Bun dentro de Node para mantener la velocidad de instalación
RUN npm install -g bun

COPY package.json bun.lock ./
RUN bun install

COPY . .

# Ejecutamos el build (esto generará dist/browser y dist/server)
RUN bun run build --configuration=production

# --- Etapa de Producción ---
FROM nginx:alpine

# ¡OJO! Revisa la ruta exacta en tu log anterior. 
# Según tu log, Angular generó los archivos en: /app/dist/pallets/browser
COPY --from=build /app/dist/pallet/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]