# IMPORTANT: Don't use this Dockerfile in your own Sapper projects without also looking at the .dockerignore file.
# Without an appropriate .dockerignore, this Dockerfile will copy a large number of unneeded files into your image.

FROM mhart/alpine-node:12

# install dependencies
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production

FROM node:14.15.4 AS builder
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run update
RUN npm run build

###
# Only copy over the Node pieces we need
# ~> Saves 35MB
###
FROM mhart/alpine-node:slim-12

WORKDIR /app
COPY --from=0 /app .
COPY --from=builder /app/__sapper__/ ./__sapper__/
COPY ./static/ ./static/
COPY ./content/ ./content/

EXPOSE 3000
CMD ["node", "__sapper__/build"]
