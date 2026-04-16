import { GraphQLError } from "graphql";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import helper from "../../helper/index";
import validate from "../../validate/index";
import SignIn from "../../models/signin";
import dotenv from "dotenv";
import { COP } from "../../models/enum";
import User from "../../models/user";
dotenv.config();
export default async (
  _: any,
  args: { input: SignIn },
  ctx: any,
  info: any,
): Promise<any> => {
  let valid = await validate.signin(args.input);
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

  let user: Partial<User> | null = null;
  if (helper.user.hasEmail(args.input.username)) {
    user = await helper.user.find<User>({
      criteria: [
        {
          column: "email",
          cop: COP.eq,
          value: args.input.username,
        },
      ],
    });
  } else {
    user = await helper.user.find<User>({
      criteria: [
        {
          column: "phone",
          cop: COP.eq,
          value: args.input.username,
        },
      ],
    });
  }

  let msg: any;
  if (user !== undefined) {
    switch (user?.status) {
      case "PENDING":
        msg = await helper.message.me(1008);
        throw new GraphQLError("An error occured", {
          extensions: {
            originalError: {
              code: msg?.code,
              message: msg?.message,
            },
          },
        });
      case "INACTIVE":
        msg = await helper.message.me(1004);
        throw new GraphQLError("An error occured", {
          extensions: {
            originalError: {
              code: msg?.code,
              message: msg?.message,
            },
          },
        });
      case "DELETED":
        msg = await helper.message.me(1005);
        throw new GraphQLError("An error occured", {
          extensions: {
            originalError: {
              code: msg?.code,
              message: msg?.message,
            },
          },
        });
    }
    let pwd = Buffer.from(args.input.password!, "base64").toString();
    let compared = await bcrypt.compare(pwd, user?.password!);
    if (compared) {
      delete user?.password;
      delete user?.creator;
      delete user?.updater;
      //user["access"] = await helper.access.get(user.roleid);
      let token = jwt.sign(user!, process.env.JWT_SECRET!, {
        expiresIn: "2h",
      });
      return token;
    } else {
      msg = await helper.message.me(1006);
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: msg?.code,
            message: msg?.message,
          },
        },
      });
    }
  } else {
    msg = await helper.message.me(1007);
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
