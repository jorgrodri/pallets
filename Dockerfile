# --- STAGE 1: Construir la aplicación Angular ---
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./

# Añade esta línea para instalar Angular CLI globalmente en la etapa de build
RUN npm install -g @angular/cli

RUN npm ci
COPY . .
RUN npm run build -- --configuration production --output-path=dist/browser

# --- STAGE 2: Servir la aplicación con Nginx ---
FROM nginx:stable-alpine AS production
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/browser /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]