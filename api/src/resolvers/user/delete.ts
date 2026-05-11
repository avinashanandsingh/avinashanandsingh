import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Update from "../../models/update";
import Insert from "../../models/insert";

export default async (_: any, args: { id: string }, ctx: any): Promise<any> => {
  let row: any;
  let table = "users";
  const user: any = ctx.user;

  await helper.data.raw("BEGIN", []);
  let update: Update = {
    table: "user_status_history",
    columns: ["active"],
    values: [false],
    criteria: [
      {
        table: "user_status_history",
        column: "userid",
        cop: COP.eq,
        value: args.id,
      },
    ],
  };

  await helper.data.update(update);

  let newState: Insert = {
    table: "user_status_history",
    columns: Object.keys({
      userid: args.id,
      status: "DELETED",
      reason: "User deleted by administrator",
    }).map((x) => {
      return { name: x };
    }),
  };
  newState.columns.push({ name: "active" });
  newState.columns.push({ name: "creator" });
  let values: any[] = Object.values({
    userid: args.id,
    status: "DELETED",
    reason: "User deleted by administrator",
  });
  values?.push(true);
  values?.push(user?.id!);

  await helper.data.insert(newState, values);

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
    await helper.data.raw("COMMIT", []);
    row = result;
  } else {
     await helper.data.raw("ROLLBACK", []);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to delete user",
        },
      },
    });
  }

  return row;
};
