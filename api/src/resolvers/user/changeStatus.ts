import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Update from "../../models/update";
import { COP } from "../../models/enum";
import Insert from "../../models/insert";
const table: string = "user_status_history";
export default async (
  _: any,
  args: { input: { userid: string; status: string; reason: string } },
  ctx: any,
): Promise<any> => {
  const user: any = ctx.user;
  await helper.data.raw("BEGIN", []);

  let input: Update = {
    table: table,
    columns: ["active"],
    values: [false],
    criteria: [
      {
        table: table,
        column: "userid",
        cop: COP.eq,
        value: args.input?.userid,
      },
    ],
  };
  await helper.data.update(input);
 

  let newState: Insert = {
    table: table,
    columns: Object.keys(args.input).map((x) => {
      return { name: x };
    }),
  };
  newState.columns.push({ name: "active" });
  newState.columns.push({ name: "creator" });
  let values: any[] = Object.values(args.input);
  values?.push(true);
  values?.push(user?.id!);

  let row = await helper.data.insert(newState, values);
  if (row) {
    input = {
      table: "users",
      columns: ["status"],
      values: [args?.input?.status],
      criteria: [
        {
          table: "users",
          column: "id",
          cop: COP.eq,
          value: args.input?.userid,
        },
      ],
    };

    input.columns.push("updater");
    input.values?.push(user.id);
    input.columns.push("updatedat");
    input.values?.push(new Date());
    await helper.data.update(input);
    await helper.data.raw("COMMIT", []);
    return row;
  } else {
    await helper.data.raw("ROLLBACK", []);
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
