import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import dotenv from "dotenv";
//import Insert from "../../models/insert";
import { COP } from "../../models/enum";
import User from "../../models/user";
dotenv.config();
export default async (
  _: any,
  args: { username: string },
  ctx: any,
  info: any,
): Promise<any> => {
  let flag: boolean = true;
  let user: Partial<User> | null = null;
  if (helper.user.hasEmail(args.username)) {
    user = await helper.user.find({
      criteria: [
        {
          column: "email",
          cop: COP.eq,
          value: args.username,
        },
      ],
    });
  } else {
    user = await helper.user.find<User>({
      criteria: [
        {
          column: "phone",
          cop: COP.eq,
          value: args.username,
        },
      ],
    });
  }  
  let msgi: any;
  if (user !== undefined) {
    switch (user?.status!) {
      case "INACTIVE":
        msgi = await helper.message.get(1004);
        throw new GraphQLError("An error occured", {
          extensions: {
            originalError: {
              ...msgi,
            },
          },
        });
      case "DELETED":
        msgi = await helper.message.get(1005);
        throw new GraphQLError("An error occured", {
          extensions: {
            originalError: {
              ...msgi,
            },
          },
        });
      /* default:
        let otp: string = helper.otp.generate();
        let input: Insert = {
          table: "otps",
          columns: [{ name: "userid" }, { name: "otp" }, { name: "createdat" }],
        };
        let row = await helper.data.insert(input, [
          user?.id,
          otp,
          helper.date.utcTimeStamp(),
        ]);
        if (row !== undefined) {
          if (helper.user.hasEmail(args.username)) {
            let templateId = process.env
              .PASSWORD_RESET_REQUEST_TEMPLATEID as string;
            helper.email.send(args.username, templateId, { otp: otp });
          } else {
            // send sms here
          }
        }

        flag = true;
        break; */
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
  return flag;
};
