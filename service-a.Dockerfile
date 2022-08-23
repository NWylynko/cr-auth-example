FROM node:18.7.0-alpine as Deps

WORKDIR /app

# copy in the files used for dependencies
COPY ./package.json ./yarn.lock ./
COPY ./service-a/package.json ./service-a/

# install all the dependencies
RUN yarn install --immutable

FROM node:18.7.0-alpine as Builder

WORKDIR /app

COPY --from=Deps /app .
COPY ./service-a/tsconfig.json ./service-a/
COPY service-a/src/ service-a/src/

# build the app
RUN yarn service-a:build

FROM node:18.7.0-alpine as Runner

WORKDIR /app

# copy in all the files needed to run
COPY --from=Builder /app/package.json ./package.json
COPY --from=Builder /app/service-a/package.json ./service-a/package.json
COPY --from=Builder /app/node_modules/ node_modules/
COPY --from=Builder /app/service-a/node_modules/ service-a/node_modules/
COPY --from=Builder /app/service-a/dist/ service-a/dist/

# expose ports the service / app listens on
EXPOSE 8080
ENV NODE_ENV=production

CMD ["yarn", "service-a:start"]