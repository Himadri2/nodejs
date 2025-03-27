FROM node:14.15.4-alpine AS builder

WORKDIR /build

COPY package*.json ./

RUN npm install

COPY . .

FROM node:14.15.4-alpine AS runner

WORKDIR /app

COPY --from=builder /build/app.js /app/app.js
COPY --from=builder /build/auth.json /app/auth.json
COPY --from=builder /build/file-utility.js /app/file-utility.js
COPY --from=builder /build/node_modules /app/node_modules
COPY --from=builder /build/package-lock.json /app/package-lock.json
COPY --from=builder /build/package.json /app/package.json
COPY --from=builder /build/views /app/views

EXPOSE 5000

CMD ["npm", "run", "start"]
