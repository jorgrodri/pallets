# Etapa 1: Build con Bun
FROM oven/bun:latest AS build

WORKDIR /app

# Copiar archivos de configuración
COPY package.json bun.lockb ./

# Instalar dependencias
RUN bun install

# Copiar el resto del código y compilar
COPY . .
RUN bun run build --configuration=production

# Etapa 2: Servidor Nginx para producción
FROM nginx:alpine

# Copiar los archivos compilados desde la etapa anterior
# Nota: Ajusta 'nombre-de-tu-app' según tu angular.json (dist/nombre-de-tu-app/browser)
COPY --from=build /app/dist/nombre-de-tu-app/browser /usr/share/nginx/html

# Copiar configuración de Nginx para manejar rutas de Angular (SPA)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]