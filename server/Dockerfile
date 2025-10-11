FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm install

COPY . .

RUN npm run build || echo "Skipping build in dev container"

EXPOSE 8080

CMD ["sh", "-c", "npm install && npm run dev"]
