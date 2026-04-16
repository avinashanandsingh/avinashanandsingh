import { GraphQLError } from "graphql";
import jwt from "jsonwebtoken";
import env from "dotenv";
import logger from "./logger";
import resolvers from "./mapping";
import { UserRole } from "../models/enum";
import User from "../models/user";
env.config();

export default async (parent: any, args: any, ctx: any, info: any) => {
  let field: string = info.fieldName;
  let headers = ctx.req.headers;
  let result;

  let logId: string = await logger.add(ctx, field);
  let resolver = resolvers.find((x: any) => x.name === field);
  if (resolver?.include) {
    let authorization = headers["authorization"];
    if (authorization === undefined) {
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: 400,
            message: "missing authorizaion token",
          },
        },
      });
    } else {
      let user: User;
      let token = authorization.replace("Bearer", "").trim();
      //let verified!: string;
      //try {

      jwt.verify(token, process.env.JWT_SECRET!);
      user = jwt.decode(token) as User;      
      if (user !== undefined) {
        ctx["user"] = user;
        //console.log(resolver.role, user?.role);
        if (resolver.role !== UserRole.ANONYMOUS) {
          if (resolver.role !== (user?.role as UserRole)) {
            throw new GraphQLError("An error occured", {
              extensions: {
                originalError: {
                  code: 403,
                  message:
                    "Your role does not authorize you to perform this action",
                },
              },
            });
          }
        }
      }
      /* } catch (e) {
        console.log(e);
        throw new GraphQLError("An error occured", {
          extensions: {
            originalError: {
              code: 401,
              message: "Token expired",
            },
          },
        });
      } */
      result = await resolver?.execute(parent, args, ctx, info);
    }
  } else {
    result = await resolver?.execute(parent, args, ctx, info);
  }

  if (result !== undefined) {
    await logger.update(logId, "SUCCEED", result);
  } else {
    await logger.update(logId, "FAILED", result);
  }
  return result;
};
