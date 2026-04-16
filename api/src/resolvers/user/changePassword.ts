import { GraphQLError } from "graphql";
import bcrypt from "bcrypt";
import helper from "../../helper/index";
import Update from "../../models/update";
import { COP } from "../../models/enum";

export default async (
  _: any,
  args: {
    id: number;
    password: string;
  }
): Promise<any> => {
  let table: string = "users";
  try {
    let user = await helper.user.get(args.id);
    let salt: number = Number(process.env.SALT);
    let newpwd: any = bcrypt.hashSync(args.password, salt);
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
            value: args?.id,
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
    }
  } catch (e: any) {
    throw new GraphQLError("Unable to change password", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  }
};
