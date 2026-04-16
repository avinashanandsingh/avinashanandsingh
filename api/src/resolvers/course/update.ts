import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Update from "../../models/update";
import { uid } from "uid";
export default async (
  _: any,
  args: { id: string; input: any },
  ctx: any,
): Promise<any> => {
  let row: any;
  let table = "courses";
  try {    
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
      let result = await helper.s3.upload(
        "thumbnails",
        imageFile,
        type,
        buffer,
      );
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

    let input: Update = {
      table: table,
      columns: Object.keys(args.input),
      values: Object.values(args.input),
      criteria: [
        {
          table,
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

    let result = await helper.data.update(input);
    if (result) {
      row = result;
    } else {
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: 1234,
            message: "unable to update category",
          },
        },
      });
    }
  } catch (e: any) {
    throw new GraphQLError("Unable to update category", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  }
  return row;
};
