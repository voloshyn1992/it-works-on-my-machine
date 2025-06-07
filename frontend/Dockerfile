FROM node:24-alpine as builder

WORKDIR /app

COPY package.json  package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

FROM gcr.io/distroless/nodejs24-debian12:nonroot

WORKDIR /app
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

EXPOSE 3000

CMD ["npm", "start"]
