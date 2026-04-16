import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import { COP } from "../../models/enum";
import Delete from "../../models/delete";

export default async (_: any, args: { id: number }, ctx: any): Promise<any> => {
  let row: any;
  let table = "referrals";

  let input: Delete = {
    table: table,    
    criteria: [
      {
        table,
        column: "id",
        cop: COP.eq,
        value: args.id,
      },
    ],
  };  
  let result = await helper.data.delete(input);
  if (result) {
    row = result;
  } else {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to delete referral",
        },
      },
    });
  }

  return row;
};
