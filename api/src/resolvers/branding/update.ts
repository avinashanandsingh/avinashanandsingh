import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Update from "../../models/update";

export default async (
  _: any,
  args: { id: number; input: any },
  ctx: any,
): Promise<any> => {
  let user: any = ctx.user;
  console.log(args.input);
  let file = args.input.file;
  delete args.input.file;

  if (file) {
    const { name, type } = file!;
    // Process the file content
    const arrayBuffer = await file!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    let result = await helper.s3.upload("brandings", name, type, buffer);
    if (result) {
      args.input["url"] = `${process.env.AWS_CDN}/brandings/${name}`;
    }
  }

  let input: Update = {
    table: "brandings",
    columns: Object.keys(args.input),
    values: Object.values(args.input),
    criteria: [
      {
        table: "brandings",
        column: "id",
        cop: COP.eq,
        value: args.id,
      },
    ],
  };

  input.columns.push("updater");
  input.values?.push(user.id);
  input.columns.push("updatedat");
  input.values?.push(new Date());

  let row = await helper.data.update(input);
  if (row !== undefined) {
    return row;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to update short",
        },
      },
    });
  }
};
