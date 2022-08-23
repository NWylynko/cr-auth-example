FROM node:18.7.0-alpine as Deps

WORKDIR /app

# copy in the files used for dependencies
COPY ./package.json ./yarn.lock ./
COPY ./service-b/package.json ./service-b/

# install all the dependencies
RUN yarn install --immutable

FROM node:18.7.0-alpine as Builder

WORKDIR /app

COPY --from=Deps /app .
COPY ./service-b/tsconfig.json ./service-b/
COPY service-b/src/ service-b/src/

# build the app
RUN yarn service-b:build

FROM node:18.7.0-alpine as Runner

WORKDIR /app

# copy in all the files needed to run
COPY --from=Builder /app/package.json ./package.json
COPY --from=Builder /app/service-b/package.json ./service-b/package.json
COPY --from=Builder /app/node_modules/ node_modules/
COPY --from=Builder /app/service-b/node_modules/ service-b/node_modules/
COPY --from=Builder /app/service-b/dist/ service-b/dist/

# expose ports the service / app listens on
EXPOSE 8080
ENV NODE_ENV=production

CMD ["yarn", "service-b:start"]