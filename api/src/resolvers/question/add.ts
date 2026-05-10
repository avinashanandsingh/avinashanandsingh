import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Insert from "../../models/insert";
export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  let user: any = ctx.user;
  let options = args.input.options;
  delete args.input.options;
  let input: Insert = {
    table: "questions",
    columns: Object.keys(args.input).map((x) => {
      return { name: x };
    }),
  };

  input.columns.push({ name: "creator" });
  let values = Object.values(args.input);
  values?.push(user?.id!);
  await helper.data.raw("BEGIN", []);
  let row = await helper.data.insert(input, values);
  if (row !== undefined) {
    options.forEach(async (option: any) => {
      let input: Insert = {
        table: "options",
        columns: [{ name: "questionid" }, { name: "title" }, { name: "sort" }],
      };
      let values = [row.id, option.title, option.sort];
      await helper.data.insert(input, values);
    });
    await helper.data.raw("COMMIT", []);
    return row;
  } else {
    await helper.data.raw("ROLLBACK", []);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to add question",
        },
      },
    });
  }
};
