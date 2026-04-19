import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import Filter from "../../models/filter";
import User from "../../models/user";
import Result from "../../models/result";

export default async (
  _: any,
  args: { filter: Filter },
  _ctx: any,
): Promise<Result<User> | null> => {
  let result: Result<User> | null = null;
  let filter = args.filter;

  let fields = await helper.data.columns([{ name: "view_users" }]);
  let input: Select = {
    tables: [
      {
        name: "view_users",
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
  result = await helper.data.select<User>(input);
  if (result !== undefined) {
    return result;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to retrieve users",
        },
      },
    });
  }
};
