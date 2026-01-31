# ---- Build Stage ----
FROM 833899002288.dkr.ecr.ap-south-2.amazonaws.com/node:18-alpine AS build
WORKDIR /app

# Install dependencies
COPY package.json ./
RUN npm install

# Copy all source files
COPY . .

# Inject build-time environment variables into public/env-config.js
# You can add more ARGs as needed for other runtime config
ARG VITE_APP_API_ENDPOINT_URL
ARG VITE_APP_TMDB_V3_API_KEY

# Build the app (Vite will copy public/ to dist/)
RUN npm run build

# ---- Production Stage ----
FROM 833899002288.dkr.ecr.ap-south-2.amazonaws.com/node:latest

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy built static files
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80


# Start nginx
CMD ["nginx", "-g", "daemon off;"]
