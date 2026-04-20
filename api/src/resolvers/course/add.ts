import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import dotenv from "dotenv";
import Insert from "../../models/insert";
import { uid } from "uid";
dotenv.config();


export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  let user: any = ctx.user;
  let image = args.input.thumbnail;
  let video = args.input.video;
  delete args.input.thumbnail;
  delete args.input.video;
  let id = uid(8);
  if (image) {
    const { name, type } = image!;
    let ext = name.split(".").pop();
    let imageFile = `${id}.${ext}`;

    // Process the file content
    const arrayBuffer = await image!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    let result = await helper.s3.upload("thumbnails", imageFile, type, buffer);
    if (result) {
      args.input["thumbnail"] =
        `${process.env.AWS_CDN}/thumbnails/${imageFile}`;
    }
  }

  if (video) {
    const { name, type } = video!;
    let ext = name.split(".").pop();
    let videoFile = `${id}.${ext}`;

    // Process the file content
    const arrayBuffer = await video!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
  
    let result = await helper.s3.upload("videos", videoFile, type, buffer);
    if (result) {
      args.input["url"] = `${process.env.AWS_CDN}/videos/${videoFile}`;
    }
  }

  let input: Insert = {
    table: "courses",
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
          message: "unable to create category",
        },
      },
    });
  }
};
