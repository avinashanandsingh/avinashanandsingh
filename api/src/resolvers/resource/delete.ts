import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Update from "../../models/update";

export default async (_: any, args: { id: number }, ctx: any): Promise<any> => {
  let row: any;
  let table = "resources";

  const user:any = ctx.user;

  let input: Update = {
    table: table,
    columns: ["status"],
    values: ["DELETED"],
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
          message: "unable to update short",
        },
      },
    });
  }

  return row;
};
