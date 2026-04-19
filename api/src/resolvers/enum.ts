import { GraphQLError } from "graphql";
import helper from "../helper/index";

export default async (
  _: any,
  args: { name: string },
  ctx: any,
): Promise<any> => {
  let list: any;
  list = await helper.enum.list(args.name);
  if (list !== undefined) {
    return list;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to retrieve templates",
        },
      },
    });
  }
};
