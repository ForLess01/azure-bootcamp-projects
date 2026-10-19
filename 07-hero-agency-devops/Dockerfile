# ==============================================================================
# PROYECTO 7: Dockerfile para Hero Agency Voting App (Stage 1: Build)
# ==============================================================================
FROM node:20-alpine AS base

WORKDIR /usr/src/app

COPY app/package*.json ./
RUN npm install --only=production --silent

COPY app/ ./

EXPOSE 8080
ENV PORT=8080
ENV NODE_ENV=production

USER node

CMD ["node", "server.js"]
