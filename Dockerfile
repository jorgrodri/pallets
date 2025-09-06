FROM node:20-alpine AS build

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar package.json y package-lock.json para instalar dependencias
COPY package.json package-lock.json ./

# Instalar las dependencias del proyecto
RUN npm install

# Copiar el resto del código fuente de la aplicación
COPY . .

# Compilar la aplicación para producción. La salida estará en /app/dist/pallet/browser
RUN npm run build

# --- Etapa 2: Servir la aplicación con Nginx ---
FROM nginx:alpine

# Copiar los archivos compilados de la etapa de 'build' al directorio web de Nginx
COPY --from=build /app/dist/pallet/browser /usr/share/nginx/html

# Copiar el archivo de configuración personalizado de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80 para acceder a la aplicación
EXPOSE 80
