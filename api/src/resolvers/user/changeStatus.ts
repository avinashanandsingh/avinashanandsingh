import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Update from "../../models/update";
import { COP } from "../../models/enum";

export default async (_: any, args: any, _ctx: any): Promise<any> => {
  let table: string = "users";
  try {
    let input: Update = {
      table: table,
      columns: ["status"],
      values: [args?.status],
      criteria: [
        {
          table,
          column: "id",
          cop: COP.eq,
          value: args?.id,
        },
      ],
    };
    let row = await helper.data.update(input);
    if (row !== undefined) {
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
  } catch (e: any) {
    throw new GraphQLError("Unable to change status", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  }
};
