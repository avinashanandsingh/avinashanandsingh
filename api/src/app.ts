import express, { Express, NextFunction, Request, Response } from "express";
import { createYoga, createSchema, maskError } from "graphql-yoga";
import { createFetch } from '@whatwg-node/fetch'
import { GraphQLError } from "graphql";
import { RedisPubSub } from "graphql-redis-subscriptions";
import * as Redis from "ioredis";
import { createEnvelopQueryValidationPlugin } from "graphql-constraint-directive";
import env from "dotenv";

import requestIp from "request-ip";
import cors from "cors";
import typeDefs from "./types/index";
import resolvers from "./resolvers/index";
// import helper from "./helper/index";
import { rateLimit } from "express-rate-limit";

import cluster from "node:cluster";
import os from "node:os";
import process from "node:process";
const numCPUs = os.cpus().length;
const options: Redis.RedisOptions = {
  host: "localhost",
  port: 6379,
  retryStrategy: (times: number) => {
    // reconnect after
    return Math.min(times * 50, 2000);
  },
};
//process.setMaxListeners(20);

const pubSub = new RedisPubSub({
  publisher: new Redis.Redis(options),
  subscriber: new Redis.Redis(options),
});

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 15 minutes
  limit: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes).
  standardHeaders: "draft-8", // draft-6: `RateLimit-*` headers; draft-7 & draft-8: combined `RateLimit` header
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers.
  ipv6Subnet: 56, // Set to 60 or 64 to be less aggressive, or 52 or 48 to be more aggressive
  // store: ... , // Redis, Memcached, etc. See below.
});

const app: Express = express();

const yoga = createYoga({
  schema: createSchema({
    typeDefs: typeDefs,
    resolvers: resolvers,
  }),
  cors: {
    origin: "*",
  },
  //multipart: true,
  context: (req) => ({ ...req, pubSub }),
  plugins: [createEnvelopQueryValidationPlugin()],
  graphqlEndpoint: "/",
  maskedErrors: {
    maskError(e) {
      let gqle = e as GraphQLError;
      console.log(e);
      return maskError(gqle.extensions?.originalError!, gqle.message, true);
    },
  },
  fetchAPI: createFetch({
    formDataLimits: {
      // 10GB in bytes
      fileSize: 10737418240, 
      files: 10,
      fieldSize: 1000000, 
      headerSize: 1000000 
    }
  })
});
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));
app.use(limiter);
app.use(cors());
app.get("/health", async (req: Request, res: Response) => {
  res.json({ status: "it work's" });
});

app.use(async (req: Request, res: Response, next: NextFunction) => {
  let r_ip = requestIp.getClientIp(req)!;
  if (r_ip === "::1") {
    r_ip = "127.0.0.1";
  }
  //console.log("r_ip: ", r_ip);
  req.headers.xip = r_ip;
  next();
});
app.use("/", yoga);
if (cluster.isPrimary) {
  console.log(`Primary ${process.pid} is running`);

  // Fork workers.
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on("exit", (worker: any, code: any, signal: any) => {
    console.log(`worker ${worker.process.pid} died`);
    // Optionally, fork a new worker to replace the dead one
    cluster.fork();
  });
} else {
  env.config();
  /*   helper.geo.cityList().then((x: any) => {
    helper.cache.set("city_list", JSON.stringify(x));
  }); */
  // Workers can share any TCP connection
  // In this case it is an HTTP server
  app.listen(process.env.PORT, async () => {
    console.log(`🚀 server started at port ${process.env.PORT}`);
  });
  console.log(`Worker ${process.pid} started`);
}
