import { GraphQLError } from "graphql";
import dotenv from "dotenv";
import helper from "../../helper/index";
import Update from "../../models/update";
import { url } from "@ffmpeg-installer/ffmpeg";
import { COP } from "../../models/enum";

dotenv.config();

export default async (
  _: any,
  args: { id: string; file: File },
  _ctx: any,
): Promise<any> => {
  let file = args.file;
  let url: string | null = null;
  if (file) {
    const { type } = file!;
    // Process the file content
    const arrayBuffer = await file!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    let result = await helper.s3.upload(
      "scan_reports",
      `report_${args.id}.pdf`,
      type,
      buffer,
    );
    
    if (result) {
      await helper.s3.invalidate("scan_reports",`report_${args.id}.pdf`);
      url = `${process.env.AWS_CDN}/scan_reports/report_${args.id}.pdf`;
    }
  }
  let input: Update = {
    table: "orders",
    columns: ["file"],
    values: [url],
    criteria: [
      {
        table: "orders",
        column: "id",
        cop: COP.eq,
        value: args.id,
      },
    ],
  };

  let result = await helper.data.update(input);
  if (result) {
    return result;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to update report",
        },
      },
    });
  }
};
