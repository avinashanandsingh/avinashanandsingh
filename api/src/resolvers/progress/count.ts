import helper from "../../helper/index";

export default async (_: any, args: any, _ctx: any): Promise<number> => {
  let input = {
    table: "view_reactions",
    criteria: args.filter.criteria,
  };
  return await helper.data.count(input);
};
