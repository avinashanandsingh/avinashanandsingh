import { Pool, QueryResult } from "pg";
const reader = new Pool({
  host: process.env.READER_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  keepAlive: true,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

const writer = new Pool({
  host: process.env.WRITER_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  keepAlive: true,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
process.setMaxListeners(20);

export default {
  write: async (sql: string, values: any[]): Promise<QueryResult> => {
    let result: QueryResult | any;
    let client = await writer.connect();

    try {
      if (values.length > 0) {
        //console.log("executed: ", sql, values);
        result = await client.query(sql, values);
      } else {
        //console.log("execute: ", sql);
        result = await client.query(sql);
      }
    } catch (e) {
      throw e;      
    } finally {
      client.release();
    }
    return result;
  },
  read: async (sql: string, values: any[]): Promise<QueryResult> => {
    let result: QueryResult | any;
    let client = await reader.connect();
    try {
      if (values && values.length > 0) {
        //console.log("executed: ", sql, values);
        result = await client.query(sql, values);
      } else {
        //console.log("execute: ", sql);
        result = await client.query(sql);
      }
    } catch (e) {
      //throw e;
      console.log(e);
    } finally {
      client.release();
    }
    //console.log("result: ", result);
    return result;
  },
};
