# build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production=false
COPY . .
# no build step required for plain node app, but keep holes for future

# runtime stage: distroless
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app /app
USER nonroot
ENV PORT=8080
CMD ["src/index.js"]
