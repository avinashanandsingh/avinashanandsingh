import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import Insert from "../../models/insert";
import User from "../../models/user";
dotenv.config();
export default async (
  _: any,
  args: { input: User },
  ctx: any,
): Promise<any> => {
  let headers = ctx.req.headers;
  let authorization = headers["authorization"];
  let token = authorization.replace("Bearer", "").trim();
  let user: any = jwt.decode(token);

  let input: Insert = {
    table: "categories",
    columns: Object.keys(args.input).map((x) => {
      return { name: x };
    }),
  };

  input.columns.push({ name: "creator" });
  let values = Object.values(args.input);
  values?.push(user?.id!);

  let row = await helper.data.insert(input, values);
  if (row !== undefined) {
    return row;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to create category",
        },
      },
    });
  }
};
