import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import dotenv from "dotenv";
import Insert from "../../models/insert";
dotenv.config();
export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  let user: any = ctx.user;  
  let thumbnail = args.input.thumbnail;
  delete args.input.thumbnail;
  let audio = args.input.audio;
  delete args.input.audio;

  if (thumbnail) {
    const { name, type } = thumbnail!;
    // Process the file content
    const arrayBuffer = await thumbnail!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    let result = await helper.s3.upload("thumbnails", name, type, buffer);
    if (result) {
      args.input["thumbnail"] = `${process.env.AWS_CDN}/thumbnails/${name}`;
    }
  }

  if (audio) {
    const { name, type } = audio!;
    // Process the file content
    const arrayBuffer = await audio!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    let result = await helper.s3.upload("audios", name, type, buffer);
    if (result) {
      args.input["url"] = `${process.env.AWS_CDN}/audios/${name}`;
    }
  }

  let input: Insert = {
    table: "meditations",
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
          message: "unable to add meditation",
        },
      },
    });
  }
};
