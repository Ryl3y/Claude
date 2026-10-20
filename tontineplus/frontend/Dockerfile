# Image web de TONTINE+ : l'appli React compilée, servie par Caddy (HTTPS automatique),
# qui relaie aussi /api et /admin vers le backend.
FROM node:20-alpine AS construction
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
# Adresse publique (https://mondomaine) : rend absolue l'image d'aperçu des liens partagés.
ARG URL_PUBLIQUE=""
ENV VITE_URL_PUBLIQUE=$URL_PUBLIQUE
RUN npm run build

FROM caddy:2-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=construction /app/dist /srv/app
