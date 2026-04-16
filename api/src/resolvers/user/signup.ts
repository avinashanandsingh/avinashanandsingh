import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import validate from "../../validate/index";
import bcrypt from "bcrypt";
import User from "../../models/user";
import dotenv from "dotenv";
import { COP } from "../../models/enum";
dotenv.config();
export default async (_: any, args: { input: User }): Promise<Partial<User> | null> => {
  let row: Partial<User> | null = null;
  let valid = await validate.signup(args.input);
  //console.log("valid: ", valid);
  if (!valid.success) {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: valid.code,
          message: valid.message,
        },
      },
    });
  }
  let pwd: any = Buffer.from(args.input.password!, "base64").toString();
  console.log("pwd: ", pwd);
  let salt: number = Number(process.env.SALT);
  args.input.password = bcrypt.hashSync(pwd, salt);
  let input = {
    table: "users",
    columns: Object.keys(args.input).map((x) => {
      return { name: x };
    }),
  };
  let values = Object.values(args.input);
  //await helper.data.raw('BEGIN',[]);
  let user = await helper.user.find<User>({
    criteria: [
      {
        column: "email",
        cop: COP.eq,
        value: args.input.email,
      },
    ],
  });

  if (user) {
    if (user?.status! === "PENDING") {
      let msg = await helper.message.me(1008);
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: msg?.code,
            message: msg?.message,
          },
        },
      });
    } else {
      let msg = await helper.message.me(1009);
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: msg?.code,
            message: msg?.message,
          },
        },
      });
    }
  }
  row = await helper.data.insert(input, values);
  //await helper.data.raw('COMMIT',[]);

  return row;
};
