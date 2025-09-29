# Build stage
FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .

# Runtime stage
FROM node:18-alpine
WORKDIR /app

# Copy app and assign ownership to 'node'
COPY --chown=node:node --from=builder /app /app

USER node

ENV PORT=8080
EXPOSE 8080

# 👇 Use the correct entrypoint
CMD ["node", "index.js"]
