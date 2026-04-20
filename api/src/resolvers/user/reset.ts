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
  },
): Promise<any> => {
  let table: string = "users";
  try {
    let otp: any = await helper.otp.verify(args.otp);
    console.log("reset.otp.row: ", otp);
    if (otp) {
      let salt: number = Number(process.env.SALT);
      let pwd: any = Buffer.from(args.password!, "base64").toString();      
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
        let user = otp.user;
        console.log("reset.user: ", user);
        let template: any = await helper.template.get(
          "EMAIL",
          "PASSWORD_RESET_CONFIRM"
        );
        let to = {
          address: user?.email!,
          name: `${user?.first_name} ${user?.last_name}`,
        };

        template.body = template.body.replace("{{first_name}}",user?.first_name);
        template.body = template.body.replace("{{last_name}}", user?.last_name);
        template.body = template.body.replace("{{year}}", (new Date()).getFullYear());
        let state = await helper.send.mail(to, template);
        if (state?.messageId) {
          return { succeed: true, message: "Password reset successful" };
        } else {
          return { succeed: false, message: "Unable to send email" };
        }
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
