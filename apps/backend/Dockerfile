FROM node:23-slim
WORKDIR /app
COPY ../../. .
RUN npm install -g pnpm
RUN pnpm install
RUN pnpm --filter backend build
WORKDIR /app/apps/backend/
CMD ["pnpm", "start:prod"]