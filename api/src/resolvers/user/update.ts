import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Update from "../../models/update";
import jwt from "jsonwebtoken";
import User from "../../models/user";

export default async (_: any, args: {id: number, input: User }, ctx: any): Promise<any> => {
  let row: any;
  let table = "users";
  try {
    let headers = ctx.req.headers;
    let authorization = headers["authorization"];
    let token = authorization.replace("Bearer", "").trim();
    let user: any = jwt.decode(token);

    let input: Update = {
      table: table,
      columns: Object.keys(args.input),
      values: Object.values(args.input),
      criteria: [
        {
          table,
          column: "id",
          cop: COP.eq,
          value: args.id,
        },
      ],
    };

    input.columns.push("updater");
    input.values?.push(user.id);
    input.columns.push("updatedat");
    input.values?.push(new Date());

    let result = await helper.data.update(input);
    if (result) {
      row = result;
    } else {
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: 1234,
            message: "unable to update user",
          },
        },
      });
    }
  } catch (e: any) {
    throw new GraphQLError("Unable to update user", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  }
  return row;
};
