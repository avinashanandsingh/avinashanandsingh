import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import { COP, LOP } from "../../models/enum";
import Criteria from "../../models/criteria";

export default async (
  _: any,
  args: { filter: any },
  _ctx: any,
): Promise<any> => {
  let row: any;
  let table = "view_pages";

  let fields = await helper.data.columns([{ name: table }]);
  let criteria: Criteria[] = [];
  let filter = args.filter;
  let keys = Object.keys(filter);
  keys.forEach((k) => {
    let row: any;
    if (k) {
      row = {
        column: k,
        cop: COP.eq,
        value: filter[k],
      };
    }
    criteria.push(row);
    if (criteria.length > 0) {
      row.lop = LOP.AND;
    }
  });
  let input: Select = {
    tables: [
      {
        name: table,
        columns: fields.map((x: any) => {
          return { name: x.name };
        }),
      },
    ],
    criteria: criteria,
  };
  let result = await helper.data.select(input);
  if (result?.count! > 0) {
    row = result?.rows?.shift();
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
