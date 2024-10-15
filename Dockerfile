FROM node:18-slim AS installer

ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV

ARG PORT=3000
ENV PORT $PORT
EXPOSE $PORT 9229 9230

RUN npm i npm@latest -g

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

USER node

WORKDIR /opt/node_app

COPY --chown=node:node package.json package-lock.json* ./
RUN npm ci && npm cache clean --force
ENV PATH /opt/node_app/node_modules/.bin:$PATH
HEALTHCHECK --interval=30s CMD node healthcheck.js

WORKDIR /opt/node_app/app
COPY --chown=node:node . .

RUN npm run build

FROM nginx:latest AS deployer

COPY --from=installer /app/build /usr/share/nginx/html
