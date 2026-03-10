# Stage 1: Build frontend
FROM node:14 as frontend-build

WORKDIR /bezkoder-ui
COPY bezkoder-ui/package.json ./
RUN npm install
COPY bezkoder-ui ./

ARG REACT_APP_API_BASE_URL
ENV REACT_APP_API_BASE_URL=$REACT_APP_API_BASE_URL

RUN npm run build

# Stage 2: Build backend
FROM node:14 as backend-build

WORKDIR /bezkoder-api
COPY bezkoder-api/package.json ./
RUN npm install --production
COPY bezkoder-api ./

# Stage 3: Final image, combine both
FROM node:14

WORKDIR /app

# Copy backend
COPY --from=backend-build /bezkoder-api /app/backend

# Copy frontend build
COPY --from=frontend-build /bezkoder-ui/build /app/frontend

# Install simple static server to serve React
RUN npm install -g serve

# Expose ports
EXPOSE 8080 3000

# Start both frontend and backend using npm concurrently
RUN npm install -g concurrently

WORKDIR /app
CMD concurrently "node backend/server.js" "serve -s frontend -l 3000"