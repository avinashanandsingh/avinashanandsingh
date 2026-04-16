import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import Filter from "../../models/filter";

export default async (
  _: any,
  args: { filter: Filter },
  ctx: any,
): Promise<any> => {
  let list: any;
  let filter = args.filter;
  let table = "view_logs";

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
    criteria: filter?.criteria,
    orderBy: filter?.orderBy,
    offset: filter?.offset,
    limit: filter?.limit,
  };
  list = await helper.data.select(input);
  if (list?.length <= 0) {
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
  return list;
};
