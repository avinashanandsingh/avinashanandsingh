import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Update from "../../models/update";
import bcrypt from "bcrypt";
import { COP } from "../../models/enum";

export default async (
  _: any,
  args: {
    otp: string;
    password: string;
  }
): Promise<any> => {
  let table: string = "users";
  try {
    let otp: any = await helper.otp.verify(args.otp);
    if (otp) {
      let salt: number = Number(process.env.SALT);
       let pwd: any = Buffer.from(args.password!, "base64").toString();
      console.log("pwd: ", pwd);
      let encrypted = bcrypt.hashSync(pwd, salt);
      let input: Update = {
        table: table,
        columns: ["password"],
        values: [encrypted],
        criteria: [
          {
            column: "id",
            cop: COP.eq,
            value: otp.userid,
          },
        ],
      };
      let row = await helper.data.update(input);
      if (row !== undefined) {        
        await helper.otp.delete(args.otp);
        let user = await helper.user.get(otp.userid);
         /* let templateId = process.env
                    .PASSWORD_RESET_CONFIRM_TEMPLATEID as string;
                  helper.send.mail(user?.email!, templateId, { name: user?.first_name! }); */
        return { succeed: true, message: "Password reset successful" };
      } else {
        return { succeed: false, message: "Unable to reset your password" };        
      }
    } else {
      return { succeed: false, message: "Invalid OTP" };      
    }
  } catch (e: any) {
    throw new GraphQLError("Unable to change status", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  }
};
