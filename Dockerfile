# Etapa 1: Compilar la aplicación con pnpm
FROM node:20-alpine AS build

# Establecer el directorio de trabajo
WORKDIR /app

# Instalar pnpm
RUN npm install -g pnpm

# Copiar archivos de manifiesto para la caché
COPY package.json pnpm-lock.yaml ./

# Instalar las dependencias con pnpm
RUN pnpm install

# Copiar el resto del código fuente
COPY . .

# Compilar la aplicación para producción
# Asumimos que el script de build es 'pnpm run build'
RUN pnpm run build

# --- Etapa 2: Servir la aplicación con Nginx ---
FROM nginx:alpine

# Copiar los archivos compilados de la etapa 'build'
COPY --from=build /app/dist/pallet/browser /usr/share/nginx/html

# Copiar el archivo de configuración personalizado de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80
EXPOSE 80
