import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Update from "../../models/update";

export default async (_: any, args: {id: number, input: any }, ctx: any): Promise<any> => {
  let row: any;
  let table = "templates";
  try {

    let user: any = ctx.user;

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
            message: "unable to update template",
          },
        },
      });
    }
  } catch (e: any) {
    throw new GraphQLError("Unable to update template", {
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
