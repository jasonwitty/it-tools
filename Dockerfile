# build stage
FROM node:lts-alpine AS build-stage
# Set environment variables for non-interactive installs (use key=value syntax)
ENV NPM_CONFIG_LOGLEVEL=warn
ENV CI=true
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
# Use the pnpm version pinned in package.json via Corepack
RUN corepack enable && corepack prepare pnpm@9.11.0 --activate
# Lockfile is out of sync with updated devDeps; install without frozen lockfile
RUN pnpm install --frozen-lockfile=false
COPY . .
RUN pnpm build

# production stage
FROM nginx:stable-alpine AS production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
