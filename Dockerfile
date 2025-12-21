# Etapa 1: Build
FROM node:20-alpine AS build
WORKDIR /app

# Instalamos bun para acelerar el proceso
RUN npm install -g bun

# Copiamos archivos de dependencias
COPY package.json bun.lock* ./
RUN bun install

# Copiamos el resto del código
COPY . .

# Ejecutamos el build de producción
RUN bun run build --configuration=production

# Etapa 2: Producción con Nginx
FROM nginx:alpine

# Limpiamos la carpeta por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*

# --- ESTA ES LA RUTA CLAVE ---
# Angular 18 pone todo en dist/[nombre-proyecto]/browser
# Según tus logs, tu proyecto se llama 'pallet'
COPY --from=build /app/dist/pallet/browser /usr/share/nginx/html

# Copiamos tu configuración de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ajustamos permisos para que los archivos sean legibles
RUN chmod -R 755 /usr/share/nginx/html && \
    chown -R nginx:nginx /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]