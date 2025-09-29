# Build stage
FROM node:18-alpine AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install --omit=dev

# Copy source code
COPY . .

# Runtime stage
FROM node:18-alpine
WORKDIR /app

# Copy app from builder stage
COPY --from=builder /app /app

# Use the built-in 'node' user for security (already in base image)
USER node

# Expose the port
ENV PORT=8080
EXPOSE 8080

# Start the app
CMD ["node", "src/index.js"]

