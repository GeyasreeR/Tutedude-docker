FROM node:18 AS builder


WORKDIR /app

COPY package*.json ./

RUN npm install 

COPY . .

FROM gcr.io/distroless/nodejs18

COPY --from=builder /app /app

WORKDIR /app

EXPOSE 3000

CMD ["server.js"]
