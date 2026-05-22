import { GraphQLError } from "graphql";
import dotenv from "dotenv";
import bcrypt from "bcrypt";
import helper from "../../helper/index";
import Insert from "../../models/insert";
import { COP } from "../../models/enum";
dotenv.config();
export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  const user: any = ctx.user;
  let course: any = await helper.course.get(args.input.courseid);
  let plain: string = helper.generatePassword(8);
  let encrypted: string | null = null;
  await helper.data.raw("BEGIN", []);
  // Create User Sections
  let values: any[] = [];
  let input: Insert = {
    table: "users",
    columns: [
      {
        name: "role",
      },
      {
        name: "first_name",
      },
      {
        name: "last_name",
      },
      {
        name: "email",
      },
      {
        name: "phone",
      },

      {
        name: "password",
      },
      {
        name: "currency",
      },
      {
        name: "verified",
      },
      {
        name: "status",
      },
      {
        name: "creator",
      },
    ],
  };
  let newUser: any = await helper.user.find({
    criteria: [
      {
        column: "email",
        cop: COP.eq,
        value: args.input.email,
      },
    ],
  });
  if (newUser == undefined) {
    let plain: string = helper.generatePassword(8);
    console.log("plain password: ", plain);
    let salt: number = Number(process.env.SALT);
    encrypted = bcrypt.hashSync(plain, salt);

    values?.push("STUDENT");
    values.push(args.input.first_name);
    values.push(args.input.last_name);
    values.push(args.input.email);
    values.push(args.input.phone);
    values.push(encrypted);
    values?.push("INR");
    values?.push(true);
    values?.push("ACTIVE");
    values?.push(user?.id!);

    newUser = await helper.data.insert(input, values);
  }
  let row: any;
  if (newUser !== undefined) {
    let expiredat: Date | null = null;
    if (course != undefined) {
      if (course.validity > 0) {
        expiredat = helper.date.add(
          args.input.enrolledat,
          "D",
          course.validity,
        );
      }
    }

    input = {
      table: "enrollments",
      columns: [
        {
          name: "userid",
        },
        {
          name: "courseid",
        },
        {
          name: "scheduleid",
        },
        {
          name: "enrolledat",
        },
        {
          name: "expiredat",
        },
        {
          name: "status",
        },
      ],
    };
    values = [];
    values?.push(newUser.id!);
    values?.push(args.input.courseid);
    values?.push(args.input.scheduleid);
    values?.push(args.input.enrolledat);
    values?.push(expiredat!);
    values?.push("ENROLLED");
    row = await helper.data.insert(input, values);
    if (row == undefined) {
      await helper.data.raw("ROLLBACK", []);
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: 1234,
            message: "unable to enroll",
          },
        },
      });
    } else {
      await helper.data.raw("COMMIT", []);
      if (encrypted != null) {
        let template: any = await helper.template.get(
          "EMAIL",
          "NEW_USER_CREATED",
        );
        let to = {
          address: args.input.email!,
          name: `${args.input.first_name} ${args.input.last_name}`,
        };
        template.body = template.body.replace(
          "{{first_name}}",
          args.input.first_name,
        );
        template.body = template.body.replace("{{last_name}}", args.input.last_name);
        template.body = template.body.replace("{{email}}", args.input.email);
        template.body = template.body.replace("{{password}}", plain);
        template.body = template.body.replace("{{year}}", new Date().getFullYear());
        await helper.send.mail(to, template);
      }
    }
  } else {
    await helper.data.raw("ROLLBACK", []);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to enroll",
        },
      },
    });
  }
  return row;
};
