# Etapa 1: Build
FROM node:20-alpine AS build
WORKDIR /app

# Instalamos bun para mayor velocidad
RUN npm install -g bun

# Copiamos dependencias primero para aprovechar el cache
COPY package.json bun.lock* ./
RUN bun install

# Copiamos el resto del código y generamos el build
COPY . .
RUN bun run build --configuration=production

# Etapa 2: Servidor de Producción (Nginx)
FROM nginx:alpine

# Limpiar archivos por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiamos los archivos generados por Angular
# Usamos 'pallet/browser' porque tu log mostró que esa es la carpeta de salida
COPY --from=build /app/dist/pallet/browser /usr/share/nginx/html

# Copiamos tu configuración de Nginx para manejar el ruteo de Angular (SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ajuste de permisos para que Nginx pueda leer las imágenes (logo.png)
RUN chmod -R 755 /usr/share/nginx/html && \
    chown -R nginx:nginx /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]