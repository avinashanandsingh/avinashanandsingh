import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Insert from "../../models/insert";
import { COP, LOP } from "../../models/enum";
import Update from "../../models/update";

export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  let user: any = ctx.user;

  let reacton = await helper.reaction.find({
    criteria: [
      {
        column: "userid",
        cop: COP.eq,
        value: user.id,
      },
      {
        column: "contextid",
        cop: COP.eq,
        lop: LOP.AND,
        value: args.input.contextid,
      },
    ],
  });

  let row: any;
  if (reacton) {
    let update: Update = {
      table: "reactions",
      columns: Object.keys(args.input),
      values: Object.values(args.input),
      criteria: [
        {
          table: "reactions",
          column: "id",
          cop: COP.eq,
          value: reacton.id,
        },
      ],
    };

    update.columns.push("updatedat");
    update.values?.push(new Date());

    row = await helper.data.update(update);
  } else {
    let input: Insert = {
      table: "reactions",
      columns: Object.keys(args.input).map((x) => {
        return { name: x };
      }),
    };

    input.columns.push({ name: "userid" });
    let values = Object.values(args.input);
    values?.push(user?.id!);

    row = await helper.data.insert(input, values);
  }
  if (row !== undefined) {
    return row;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to add new reaction",
        },
      },
    });
  }
};
