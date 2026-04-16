import { GraphQLError } from "graphql";
import dotenv from "dotenv";
import helper from "../../helper/index";
import Insert from "../../models/insert";

dotenv.config();

export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  let user: any = ctx.user;
  console.log(args.input);
  let file = args.input.file;
  delete args.input.file;
  
  if (file) {
    const { name, type } = file!;    
    // Process the file content
    const arrayBuffer = await file!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    let result = await helper.s3.upload("modules", name, type, buffer);
    if (result) {
      args.input["url"] =
        `${process.env.AWS_CDN}/modules/${name}`;
    }
  }

  let input: Insert = {
    table: "modules",
    columns: Object.keys(args.input).map((x) => {
      return { name: x };
    }),
  };

  input.columns.push({ name: "creator" });
  let values = Object.values(args.input);
  values?.push(user?.id!);

  let row = await helper.data.insert(input, values);
  if (row !== undefined) {
    return row;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to create resource",
        },
      },
    });
  }
};
