# --- STAGE 1: Construir la aplicación Angular ---
# Usamos la versión EXACTA de Node.js que tienes en tu PC (22.17.1).
# 'alpine' es una distribución ligera que reduce el tamaño final de la imagen.
FROM node:22-alpine AS build

# Establece el directorio de trabajo dentro del contenedor Docker.
WORKDIR /app

# Copia los archivos de definición de dependencias primero.
# Esto es crucial para aprovechar el caché de Docker y acelerar las builds.
COPY package.json package-lock.json ./

# Instala las dependencias de Node.js.
# 'npm ci' asegura una instalación limpia y reproducible, basada en package-lock.json.
RUN npm ci

# Copia el resto de los archivos de tu proyecto Angular.
COPY . .

# Genera la build de producción de tu aplicación Angular.
# Asegúrate de que tu angular.json esté configurado para que la salida sea 'dist/browser'.
# `--output-path=dist/browser` es una buena práctica para la consistencia.
RUN npm run build -- --configuration production --output-path=dist/browser

# --- STAGE 2: Servir la aplicación con Nginx ---
# Utilizamos Nginx, un servidor web ligero y eficiente, para servir los archivos estáticos.
FROM nginx:stable-alpine AS production

# Copia la configuración personalizada de Nginx.
# Este archivo es CRUCIAL para que el enrutamiento de Angular (SPAs) funcione correctamente.
# DEBES tener un archivo 'nginx.conf' en la misma carpeta que tu Dockerfile.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia los archivos estáticos de Angular ya construidos desde la etapa anterior ('build').
# La ruta '/app/dist/browser' debe coincidir con el 'output-path' de tu comando 'ng build'.
COPY --from=build /app/dist/browser /usr/share/nginx/html

# Expone el puerto 80, que es el puerto por defecto que Nginx usará para servir tu app.
EXPOSE 80

# Comando para iniciar Nginx en primer plano.
# Esto es necesario para que Docker mantenga el contenedor en ejecución.
CMD ["nginx", "-g", "daemon off;"]