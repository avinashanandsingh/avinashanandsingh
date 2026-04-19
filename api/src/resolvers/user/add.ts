import { GraphQLError } from "graphql";
import generator from "generate-password";
import helper from "../../helper/index";
import bcrypt from "bcrypt";
import dotenv from "dotenv";
import Insert from "../../models/insert";
import { IUserData } from "../../models/user";
import { COP } from "../../models/enum";
dotenv.config();
const getPassword = (): string => {
  let password = generator.generate({
    length: 12,
    numbers: true,
    symbols: true,
    uppercase: true,
    excludeSimilarCharacters: true,
  });
  console.log(password);
  return password;
};
export default async (
  _: any,
  args: { input: IUserData },
  ctx: any,
): Promise<any> => {
  let user: any = ctx.user;

  let exist = await helper.user.find({
    criteria: [
      {
        column: "email",
        cop: COP.eq,
        value: args.input.email,
      },
    ],
  });
  if (exist) {
    let msg = await helper.message.me(1011);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: msg?.code,
          message: msg?.message,
        },
      },
    });
  }

  let file = args.input.file;
  delete args.input.file;
  let iuser: any = args.input;
  if (file) {
    const { name, type } = file!;
    // Process the file content
    const arrayBuffer = await file!.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    let result = await helper.s3.upload("avatars", name, type, buffer);
    if (result) {
      iuser["avatar"] = `${process.env.AWS_CDN}/avatars/${name}`;
    }
  }

  let pwd: any = getPassword();
  console.log("user.add.pwd: ", pwd);
  let salt: number = Number(process.env.SALT);
  let encrypted = bcrypt.hashSync(pwd, salt);
  iuser["password"] = encrypted;
  iuser["verified"] = true;
  iuser["status"] = "ACTIVE";
  iuser["creator"] = user?.id;

  let input: Insert = {
    table: "users",
    columns: Object.keys(iuser).map((x) => {
      return { name: x };
    }),
  };

  let values = Object.values(iuser);
  let row = await helper.data.insert(input, values);
  if (row !== undefined) {
    let template: any = await helper.template.get("EMAIL", "NEW_USER_CREATED");
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
    template.body = template.body.replace("{{email}}", args.input.email);
    template.body = template.body.replace("{{password}}", pwd);
    helper.send.mail(to, template);
    return row;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to create user",
        },
      },
    });
  }
};
