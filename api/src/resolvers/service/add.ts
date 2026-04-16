import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import Insert from "../../models/insert";
dotenv.config();
export default async (
  _: any,
  args: { input: any },
  ctx: any,
): Promise<any> => {
  
  let user: any = ctx.user;
  let slots = args.input.timeslots;
  delete args.input.timeslots;
  let input: Insert = {
    table: "services",
    columns: Object.keys(args.input).map((x) => {
      return { name: x };
    }),
  };

  input.columns.push({ name: "creator" });
  let values = Object.values(args.input);
  values?.push(user?.id!);
  await helper.data.raw('BEGIN',[]);
  let row = await helper.data.insert(input, values);
  if (row !== undefined) {    
    slots.forEach(async (slot: any) => {
      let input: Insert = {
        table: "timeslots",
        columns: [
          { name: "serviceid" },
          { name: "name" },
          { name: "start_time" },
          { name: "end_time" },
        ],
      };
      let values = [row.id, slot.name, slot.start_time, slot.end_time];
      await helper.data.insert(input, values);
    });
    await helper.data.raw('COMMIT',[]);
    return row;
    
  } else {
    await helper.data.raw('ROLLBACK',[]);
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to create service",
        },
      },
    });
  }
};
