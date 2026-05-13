import helper from "../../helper/index";
import Select from "../../models/select";
import { COP, LOP } from "../../models/enum";
const view = "view_enrollments";
export default async (
  _: any,
  args: { courseId: string, userId: string},
  ctx: any,
): Promise<any> => {
  let row: any;
  let user = ctx.user;
  let schedule = await helper.schedule.find({
    criteria: [
      {
        column: "courseid",
        cop: COP.eq,
        value: args.courseId,
      },
      {
        column: "status",
        cop: COP.eq,
        lop: LOP.AND,
        value: "ACTIVE",
      },
    ],
  });
  let fields = await helper.data.columns([{ name: view }]);
  if (schedule) {
    let input: Select = {
      tables: [
        {
          name: view,
          columns: fields.map((x: any) => {
            return { name: x.name };
          }),
        },
      ],
      criteria: [
        {
          table: view,
          column: "courseid",
          cop: COP.eq,
          value: args.courseId,
        },
        {
          table: view,
          column: "scheduleid",
          cop: COP.eq,
          lop: LOP.AND,
          value: schedule.id,
        },
      ],
    };
    if (args.userId) {
      input.criteria?.push({
        table: view,
        column: "userid",
        cop: COP.eq,
        lop: LOP.AND,
        value: args.userId,
      });
    }
    let result = await helper.data.select<any>(input);
    console.log(result);
    row = result?.rows?.shift();
  }

  return row;
};
