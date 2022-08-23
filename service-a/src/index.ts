import fastify from "fastify";

const app = fastify({ logger: true });

app.get('/', () => ({ name: `service-a` }))

const port = Number(process.env.PORT ?? "8080")
app.listen({ port, host: "0.0.0.0" })