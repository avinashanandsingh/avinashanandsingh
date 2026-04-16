import pg from "pg";
import env from "dotenv";
env.config();

const readerPool = new Map();
const writerPool = new Map();

export default {
  reader(db: string): pg.Pool {
    if (!readerPool.has(db)) {
      readerPool.set(
        db,
        new pg.Pool({
          host: process.env.READER_HOST,
          port: Number(process.env.DB_PORT),
          user: process.env.DB_USER,
          password: process.env.DB_PASS,
          database: db,
          keepAlive: true,
          max: 20,
          idleTimeoutMillis: 30000,
          connectionTimeoutMillis: 2000,
        }),
      );
    }
    return readerPool.get(db)!;
  },

  writer(db: string): pg.Pool {
    if (!writerPool.has(db)) {
      writerPool.set(
        db,
        new pg.Pool({
          host: process.env.READER_HOST,
          port: Number(process.env.DB_PORT),
          user: process.env.DB_USER,
          password: process.env.DB_PASS,
          database: db,
          keepAlive: true,
          max: 20,
          idleTimeoutMillis: 30000,
          connectionTimeoutMillis: 2000,
        }),
      );
    }
    return writerPool.get(db)!;
  },
};
