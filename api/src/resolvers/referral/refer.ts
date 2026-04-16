import { GraphQLError } from "graphql";
import dotenv from "dotenv";
import helper from "../../helper/index";
import Insert from "../../models/insert";

dotenv.config();

export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  let user: any = ctx.user;
  let input: Insert = {
    table: "referrals",
    columns: Object.keys(args.input).map((x) => {
      return { name: x };
    }),
  };

  input.columns.push({ name: "referrer" });
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
          message: "unable to refer",
        },
      },
    });
  }
};
