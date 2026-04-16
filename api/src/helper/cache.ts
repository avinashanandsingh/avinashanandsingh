import Redis from "ioredis";
const redis = new Redis();
export default {
  async set(key: string, value: string, seconds?: number) {
    if (seconds) {
      await redis.set(key, value, "EX", seconds);
    } else {
      await redis.set(key, value);
    }
  },
  async get(key: string) {
    let value = await redis.get(key);
    return value;
  },
  async remove(key: string) {
    return await redis.del(key);
  },
  async clear() {
    return await redis.flushall();
  },
};
