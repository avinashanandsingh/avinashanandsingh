import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Select from "../../models/select";
import Filter from "../../models/filter";

export default async (
  _: any,
  args: { filter: Filter },
  ctx: any
): Promise<any> => {
  let list: any;
  let filter = args.filter;
  try {
    let fields = await helper.data.columns([{ name: "messages" }]);
    let input: Select = {
      tables: [
        {
          name: "messages",
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
    if (list !== undefined) {
      return list;
    } else {
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: 1234,
            message: "unable to retrieve messages",
          },
        },
      });
    }
  } catch (e: any) {
    throw new GraphQLError("Unable to retrieve messages", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  }
};
