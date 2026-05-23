import { GraphQLError } from "graphql";
import helper from "../../helper/index";
import Insert from "../../models/insert";
import { COP, LOP } from "../../models/enum";
import Update from "../../models/update";
import Criteria from "../../models/criteria";

export default async (_: any, args: { input: any }, ctx: any): Promise<any> => {
  let user: any = ctx.user;
  console.log("track.input: ", args.input);
  let moduleExist: any = await helper.module.get(args.input.moduleId);
  console.log("track.module.exist: ", moduleExist);
  let criteria: Criteria[] = [
    {
      column: "userid",
      cop: COP.eq,
      value: user.id,
    },
    {
      column: "moduleid",
      cop: COP.eq,
      lop: LOP.AND,
      value: moduleExist?.id,
    },
  ];

  if (args.input.enrollmentId) {
    criteria.push({
      column: "enrollmentid",
      cop: COP.eq,
      lop: LOP.AND,
      value: args.input.enrollmentId,
    });
  }

  let exist = await helper.progress.find({
    criteria: criteria,
  });
  console.log("track.progress.exist: ", exist);
  let row: any;
  if (exist) {
    let columns: string[] = ["time_spent"];
    let values: any[] = [args.input.timeSpent];
    if (args.input.completed) {
      columns.push("completed");
      values.push(args.input.completed);
    }

    if (args.input.completedat) {
      columns.push("completedat");
      values.push(args.input.completedat);
    }

    let update: Update = {
      table: "progress",
      columns: columns,
      values: values,
      criteria: [
        {
          table: "progress",
          column: "id",
          cop: COP.eq,
          value: exist.id,
        },
      ],
    };
    row = await helper.data.update(update);
  } else {
    let icolumns: any[] = [{ name: "userid" }, { name: "time_spent" }];
    let ivalues: any[] = [user.id, args.input.timeSpent];
    
    if (args.input.moduleId) {
      icolumns.push({ name: "moduleid" });
      ivalues.push(args.input.moduleId);
    }

    if (args.input.completed) {
      icolumns.push({ name: "completed" });
      ivalues.push(args.input.completed);
    }

    if (args.input.completedat) {
      icolumns.push({ name: "completedat" });
      ivalues.push(args.input.completedat);
    }

    let input: Insert = {
      table: "progress",
      columns: icolumns,
    };
    row = await helper.data.insert(input, ivalues);
  }

  if (row == undefined) {
    throw new GraphQLError("An error occured", {
      extensions: {
        originalError: {
          code: 1234,
          message: "unable to update progress",
        },
      },
    });
  }
  return row;
};
