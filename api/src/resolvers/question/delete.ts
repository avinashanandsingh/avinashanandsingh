import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Delete from "../../models/delete";

export default async (
  _: any,
  args: { id: string },
  _ctx: any,
): Promise<any> => {
  let row: any;
  let table = "questions";

  await helper.data.raw("BEGIN", []);
  let del = {
    table: "options",
    criteria: [
      {
        column: "questionid",
        cop: COP.eq,
        value: args.id,
      },
    ],
  };
  await helper.data.delete(del);
  let input: Delete = {
    table: table,
    criteria: [
      {
        table,
        column: "id",
        cop: COP.eq,
        value: args.id,
      },
    ],
  };

  let result = await helper.data.delete(input);
  if (result) {
    await helper.data.raw("COMMIT", []);
    row = result;
  } else {
    await helper.data.raw("ROLLBACK", []);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to delete question",
        },
      },
    });
  }

  return row;
};
