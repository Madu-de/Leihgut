FROM node:23-slim AS builder
WORKDIR /app
COPY ../../. .
RUN npm install -g pnpm
RUN pnpm install
RUN pnpm --filter frontend build

FROM nginx:alpine
COPY --from=builder app/apps/frontend/dist/frontend /usr/share/nginx/html