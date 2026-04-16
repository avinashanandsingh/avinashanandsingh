import { uid } from "uid";
import data from "./data/index";
import { COP } from "../models/enum";
import Update from "../models/update";
import Insert from "../models/insert";
export default {
  add: async (row: any): Promise<string> => {
    let id: string;
    let newId = uid(8);
    let table = "auditlogs";
    try {
      row["id"] = newId;
      let columns = Object.keys(row);
      let args: Insert = {
        table: table,
        columns: columns.map((x) => {
          return { name: x };
        }),
      };

      let result = (await data.insert(args, Object.values(row))) as any;
      if (result !== null) {
        id = result?.id;
      }
    } catch (e) {
      console.log(e);
    }
    return id!;
  },
  update: async (rowId: string, row: any): Promise<string> => {
    let id: string;
    let table = "auditlogs";
    try {
      let args: Update = {
        table: table,
        columns: Object.keys(row).map((x) => {
          return x;
        }),
        values: Object.keys(row).map((x) => {
          return row[x];
        }),
        criteria: [
          {
            table,
            column: "id",
            cop: COP.eq,
            value: rowId,
          },
        ],
      };
      let result: any = await data.update(args);
      if (result !== undefined) {
        id = result?.id;
      }
    } catch (e) {
      console.log(e);
    }
    return id!;
  },
};
