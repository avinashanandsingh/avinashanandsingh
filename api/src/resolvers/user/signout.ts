import Cache from "node-cache";
export default async (
  _: any,
  _args: any,
  ctx: any,
  _info: any,
): Promise<boolean> => {
  let cache = new Cache();
  let authorization = ctx.req.headers["authorization"];
  let token = authorization.replace("Bearer", "").trim();

  cache.set(`bl_${token}`, token, 100);
  return true;
};
