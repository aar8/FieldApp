import { createServer } from "./server.js";

const port = Number(process.env.PORT ?? 8080);

const app = createServer();

app.listen(port, () => {
  console.log(`FieldPrime server listening on http://localhost:${port}/api`);
});
