# --- ETAPA 1: Build ---
# Usamos directamente la imagen de Bun (más ligera que Node + Bun)
FROM oven/bun:alpine AS build
WORKDIR /app

# Copiamos archivos de dependencias e instalamos
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile

# Copiamos el resto del código
COPY . .

# Ejecutamos el build de producción
# Nota: Bun ejecutará el CLI de Angular mucho más rápido
RUN bun run build --configuration=production

# --- ETAPA 2: Producción con Nginx ---
FROM nginx:alpine

# Limpiamos la carpeta por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiamos los archivos estáticos desde el builder
# Asegúrate de que 'pallet' sea el nombre en tu angular.json
COPY --from=build /app/dist/pallet/browser /usr/share/nginx/html

# Copiamos tu configuración de Nginx para manejar el routing de Angular (SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ajustamos permisos básicos
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]