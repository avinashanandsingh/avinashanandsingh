import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import validate from "../../validate/index";
import bcrypt from "bcrypt";
import User from "../../models/user";
import dotenv from "dotenv";
import { COP } from "../../models/enum";
import Insert from "../../models/insert";
dotenv.config();
export default async (
  _: any,
  args: { input: User },
): Promise<Partial<User> | null> => {
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
  let referral = await helper.referral.find({
    criteria: [
      {
        column: "email",
        cop: COP.eq,
        value: args.input.email?.toLowerCase(),
      },
    ],
  });
  
  
  if (referral) {
    input.columns.push({ name: "referrerid" });
    values.push(referral.referrer);
  }
  row = await helper.data.insert(input, values);
  //await helper.data.raw('COMMIT',[]);
  if (row) {
    await helper.referral.update(referral?.id!, {
      acceptedat: helper.date.utcTimeStamp(),
    });

    let otp: string = helper.otp.generate();
    let otpInput: Insert = {
      table: "password_resets",
      columns: [{ name: "userid" }, { name: "otp" }],
    };
    let otp_row = await helper.data.insert(otpInput, [row.id, otp]);

    let template: any = await helper.template.get(
      "EMAIL",
      "EMAIL_VERIFICATION",
    );
    let to = {
      address: args.input.email!,
      name: `${args.input.first_name} ${args.input.last_name}`,
    };
    template.body = template.body.replace(
      "{{first_name}}",
      args.input.first_name
    );
    template.body = template.body.replace(
      "{{last_name}}",
      args.input.last_name
    );
    template.body = template.body.replace("{{otp}}", otp);
    template.body = template.body.replace("{{year}}", new Date().getFullYear());
    await helper.send.mail(to, template);
  }
  return row;
};
