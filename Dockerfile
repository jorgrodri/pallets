# Etapa 1: Construcción (Build)
FROM node:20-alpine AS build
WORKDIR /app

# Instalamos bun para una instalación más rápida de dependencias
RUN npm install -g bun

# Copiamos archivos de configuración de dependencias
COPY package.json bun.lock* ./
RUN bun install

# Copiamos todo el código fuente del proyecto
COPY . .

# Ejecutamos el build de producción
# Esto generará los archivos en /app/dist/pallet/browser
RUN bun run build --configuration=production

# Etapa 2: Servidor de Producción (Nginx)
FROM nginx:alpine

# 1. Limpiamos el contenido por defecto de Nginx para evitar conflictos
RUN rm -rf /usr/share/nginx/html/*

# 2. Copiamos el contenido de la subcarpeta 'browser' (donde Angular pone el index.html, JS, CSS y el logo)
# Según tus logs, la ruta exacta es: /app/dist/pallet/browser
COPY --from=build /app/dist/pallet/browser /usr/share/nginx/html

# 3. Copiamos tu archivo de configuración de Nginx (para manejar SPA y caché)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 4. PASO CRUCIAL PARA LAS IMÁGENES Y ESTILOS:
# Ajustamos permisos para que el servidor Nginx (Linux) pueda leer logo.png y el favicon
RUN chmod -R 755 /usr/share/nginx/html && \
    chown -R nginx:nginx /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]