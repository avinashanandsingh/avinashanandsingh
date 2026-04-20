import { GraphQLError } from "graphql";
import bcrypt from "bcrypt";
import helper from "../../helper/index";
import Update from "../../models/update";
import { COP } from "../../models/enum";

export default async (
  _: any,
  args: {
    password: string;
  },
  ctx: any,
  _info: any,
): Promise<any> => {
  let table: string = "users";
  let user = ctx.user;
  let salt: number = Number(process.env.SALT);
  let pwd: any = Buffer.from(args.password!, "base64").toString();
  let newpwd = bcrypt.hashSync(pwd, salt);
  if (user) {
    let input: Update = {
      table: table,
      columns: ["password"],
      values: [newpwd],
      criteria: [
        {
          table,
          column: "id",
          cop: COP.eq,
          value: user?.id,
        },
      ],
    };
    let row = await helper.data.update(input);
    if (row !== undefined) {
      return {
        succeed: true,
        message: "Password changed successfully",
      };
    } else {
      return {
        succeed: false,
        message: "Unable to change password",
      };
    }
  } else {
    let msg = await helper.message.me(1007);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: msg?.code,
          message: msg?.message,
        },
      },
    });
  }
};
