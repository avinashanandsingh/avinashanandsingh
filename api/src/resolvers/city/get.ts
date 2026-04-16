import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import { COP } from "../../models/enum";
import City from "../../models/city";

export default async (_: any, args: any, ctx: any): Promise<Partial<City> | null> => {
  let row: Partial<City> | null = null;
  let table = "view_cities";

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
        column: "id",
        cop: COP.eq,
        value: args.id,
      },
    ],
  };
  let result = await helper.data.select(input);
  if (result?.count! > 0) {
    row = result?.rows?.shift() as Partial<City>;
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
