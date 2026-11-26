FROM node:22-slim

WORKDIR /home/app

# Primero las dependencias: la capa se reutiliza mientras package.json no cambie
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY index.js ./

EXPOSE 3000

CMD ["node", "index.js"]
