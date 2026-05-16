import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import { COP, LOP } from "../../models/enum";

export default async (
  _: any,
  args: { id: string; context: string },
  ctx: any,
): Promise<boolean> => {
  let flag: boolean = false;
  let table = "view_orders";
  const user = ctx.user;
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
    criteria: [
      {
        table,
        column: "context",
        cop: COP.eq,
        value: args.context,
      },
      {
        table,
        column: "contextid",
        cop: COP.eq,
        lop: LOP.AND,
        value: args.id,
      },
      {
        table,
        column: "order_status",
        cop: COP.eq,
        lop: LOP.AND,
        value: "CONFIRMED",
      },
      {
        table,
        column: "createdby",
        cop: COP.eq,
        lop: LOP.AND,
        value: user.id,
      },
    ],
  };
  let result = await helper.data.select<any>(input);
  if (result?.count! > 0) {
    flag = true;
  }
  return flag;
};
