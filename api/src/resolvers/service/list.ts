import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import Filter from "../../models/filter";
import Result from "../../models/result";

export default async (
  _: any,
  args: { filter: Filter },
  ctx: any,
): Promise<Result<any> | null> => {
  let result: Result<any> | null = null;
  let filter = args.filter;

  let fields = await helper.data.columns([{ name: "view_services" }]);
  let input: Select = {
    tables: [
      {
        name: "view_services",
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
  result = await helper.data.select<any>(input);
  if (result?.count! > 0) {
    return result;
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
};
