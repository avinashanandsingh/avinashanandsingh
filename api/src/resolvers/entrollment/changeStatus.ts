import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Update from "../../models/update";
import { COP } from "../../models/enum";
const table: string = "enrollments";
export default async (
  _: any,
  args: { id: string; status: string },
  ctx: any,
): Promise<any> => {
  const user: any = ctx.user;

  let input: Update = {
    table: table,
    columns: ["status"],
    values: [args.status],
    criteria: [
      {
        table: table,
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

  let row = await helper.data.update(input);
  if (row) {
    return row;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to change status",
        },
      },
    });
  }
};
