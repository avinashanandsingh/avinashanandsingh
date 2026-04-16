import { GraphQLError } from "graphql";
import jwt from "jsonwebtoken";
import env from "dotenv";
env.config();
export default async (_: any, args: any, ctx: any): Promise<any> => {
  let verified = false;
  let payload:any;
  //try {
    if (args.token.trim().length > 0) {
      payload = jwt.verify(args.token, process.env.JWT_SECRET!);
      verified = payload !== undefined;
    }
    //console.log(payload);
  /* } catch (e: any) {
    console.log(payload);
    throw new GraphQLError("Unable to verify token", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  } */
  return verified;
};
