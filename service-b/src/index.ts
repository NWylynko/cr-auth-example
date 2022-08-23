import fastify from "fastify";
import { GoogleAuth } from 'google-auth-library';
import Axios from "axios";

const app = fastify({ logger: true });

const auth = new GoogleAuth();

// we will pass the service-a url through as an environment variable
const baseURL = process.env.SERVICE_A_URL;

if (!baseURL) {
  throw new Error(`env SERVICE_A_URL not set`)
}

app.get('/', async () => {

  // first we have to get an Id Token Client, we have to
  // pass through the service we want to communicate with
  const client = await auth.getIdTokenClient(baseURL);

  // Next we want to get a jwt that we can use
  // this jwt has an expiry of 1 hour
  // you will want a setInterval() to fetch a new one every hour
  const headers = await client.getRequestHeaders();

  const axios = Axios.create({
    baseURL,
    headers
  })

  // make the request to service a
  const { data: result } = await axios.get('/');

  return { name: `service-b`, result }
})

const port = Number(process.env.PORT ?? "8080")
app.listen({ port, host: "0.0.0.0" })