# build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app /app
USER nonroot
ENV PORT=8080
CMD ["src/index.js"]
