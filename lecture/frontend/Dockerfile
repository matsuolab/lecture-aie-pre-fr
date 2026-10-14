# --- Étape de construction ---
FROM node:22-slim AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
RUN npm run build

# --- Étape d'exécution ---
# Servir les fichiers statiques compilés avec une image nginx légère
FROM nginx:alpine AS runner

# Placer uniquement les fichiers générés par vite (dist) dans le répertoire public de nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuration du proxy inverse de /app/api vers le conteneur backend
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Écouter sur le port 80 (configuration par défaut de l'image nginx)
EXPOSE 80
