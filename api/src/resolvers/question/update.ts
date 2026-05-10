import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Update from "../../models/update";
import jwt from "jsonwebtoken";
import Insert from "../../models/insert";
import Delete from "../../models/delete";

export default async (_: any, args: {id: string, input: any }, ctx: any): Promise<any> => {
  let row: any;
  let table = "questions";
  let options = args.input.options;
  delete args.input.options;
  try {
    let headers = ctx.req.headers;
    let authorization = headers["authorization"];
    let token = authorization.replace("Bearer", "").trim();
    let user: any = jwt.decode(token);

    let input: Update = {
      table: table,
      columns: Object.keys(args.input),
      values: Object.values(args.input),
      criteria: [
        {
          table,
          column: "id",
          cop: COP.eq,
          value: args.id,
        },
      ],
    };

    input.columns.push("updater");
    input.values?.push(user.id);
    input.columns.push("updatedat");
    input.values?.push(new Date());
    await helper.data.raw("BEGIN", []);
    let result = await helper.data.update(input);
    if (result) {
      row = result;
        let del:Delete = {
          table:"options",
          criteria:[{
            column :"questionid",
            cop:COP.eq,
            value: args.id,
          }]
        }
        await helper.data.delete(del);
        options.forEach(async (option: any) => {
            let input: Insert = {
              table: "options",
              columns: [{ name: "questionid" }, { name: "title" }, { name: "sort" }],
            };
            let values = [args.id, option.title, option.sort];
            await helper.data.insert(input, values);
          });
          await helper.data.raw("COMMIT", []);
    } else {
      await helper.data.raw("ROLLBACK", []);
      throw new GraphQLError("An error occured", {
        extensions: {
          originalError: {
            code: 1234,
            message: "unable to update question",
          },
        },
      });
    }
  } catch (e: any) {
    throw new GraphQLError("Unable to update category", {
      extensions: {
        originalError: {
          code: 500,
          message: e.message,
        },
      },
    });
  }
  return row;
};
