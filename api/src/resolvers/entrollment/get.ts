import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import { COP } from "../../models/enum";
import Filter from "../../models/filter";

export default async (_: any, args: { filter: Filter }, _ctx: any): Promise<any> => {
  let row: any;
  let table = "view_enrollments";
  let fields = await helper.data.columns([{ name: table }]);
  let input: Select = {
    tables: [
      {
        name: table,
        columns: fields.map((x: any) => {
          return { name: x.name };
        }),
      },
    ],
    criteria: args.filter.criteria
  };
  let result = await helper.data.select<any>(input);
  if (result?.count! > 0) {
    row = result.rows?.shift();
  } else {
    let msg = await helper.message.me(204);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: msg?.code,
          message: msg?.message,
        },
      },
    });
  }

  return row;
};
