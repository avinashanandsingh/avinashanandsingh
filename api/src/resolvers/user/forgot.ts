import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Insert from "../../models/insert";
import { COP } from "../../models/enum";
import User from "../../models/user";

export default async (
  _: any,
  args: {
    email: string;
  }
): Promise<any> => {
  let table: string = "password_resets";
  try {    
    let user = await helper.user.find<User>({
      criteria: [
        {
          column: "email",
          cop: COP.eq,
          value: args.email,
        },
      ],
    });
    if (user) {
      if (user.status === "ACTIVE") {
        let now = new Date(); //;
        let active = await helper.otp.active(user?.id!);
        let created = new Date(active?.createdat);
        let diff = Math.abs(now.getTime() - created.getTime());
        let minutes = Math.floor(diff / 1000 / 60);
        if (active && minutes <= 10) {
          return { succeed: false, message: "OTP available after 10 minutes" };
        }
        let otp: string = helper.otp.generate();
        let input: Insert = {
          table: table,
          columns: [{ name: "userid" }, { name: "otp" }, { name: "createdat" }],
        };
        let row = await helper.data.insert(input, [user.id, otp, now]);
        if (row !== undefined) {
        let template: any = await helper.template.get("EMAIL", "RESET_PASSWORD_REQUEST");
            let to = {
              address: user.email!,
              name: `${user.first_name} ${user.last_name}`,
            };
        
            template.body = template.body.replace("{{first_name}}", user.first_name);
            template.body = template.body.replace("{{last_name}}", user.last_name);
            template.body = template.body.replace("{{otp}}", otp);
            template.body = template.body.replace("{{year}}", (new Date()).getFullYear());
            let state = await helper.send.mail(to, template);
            if(state?.messageId){
              return { succeed: true, message: "OTP sent to your email" };
            }else{
              return { succeed: false, message: "Unable to send email" };
            }
        } else {
          return { succeed: true, message: "Unable to generate OTP" };
        }
      } else {
        return { succeed: true, message: "Your account is inactive" };
      }
    } else {
      return { succeed: true, message: "Your account does not exist" };
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
