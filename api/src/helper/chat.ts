import Delete from "../models/delete";
import { COP } from "../models/enum";
import Filter from "../models/filter";
import Insert from "../models/insert";

import Select from "../models/select";
import Update from "../models/update";
import data from "./data/index";
const table: string = "chats";
export default {
  get: async (id?: number): Promise<Partial<any> | null> => {
    let row: Partial<any> | null = null;
    try {
      let columns = await data.columns([{ name: "view_chats" }]);
      let input: Select = {
        tables: [
          {
            name: "view_chats",
            columns: columns.map((x: any) => {
              return { name: x.name };
            }),
          },
        ],
        criteria: [
          {
            table,
            column: "id",
            cop: COP.eq,
            value: id,
          },
        ],
      };
      let result = await data.select(input);
      row = result.rows?.shift()!;
    } catch (e) {}
    return row;
  },
  find: async (filter: Filter): Promise<Partial<any> | null> => {
    let row: Partial<any> | null = null;
    try {
      let columns = await data.columns([{ name: "view_chats" }]);
      let input: Select = {
        tables: [
          {
            name: "view_chats",
            columns: columns.map((x: any) => {
              return { name: x.name };
            }),
          },
        ],
        criteria: filter.criteria,
        orderBy: filter.orderBy,
        offset: filter.offset,
        limit: filter.limit,
      };
      let result = await data.select(input);
      row = result.rows?.shift()!;
    } catch (e) {
      throw e;
    }
    return row;
  },
  async add(row: any): Promise<any> {
    let input: Insert = {
      table: table,
      columns: Object.keys(row).map((x) => {
        return { name: x };
      }),
    };
    let values = Object.values(row);
    return await data.insert(input, values);
  },
  async update(id: string, row: any): Promise<any> {
    let input: Update = {
      table: table,
      columns: Object.keys(row.input),
      values: Object.values(row.input),
      criteria: [
        {
          table,
          column: "id",
          cop: COP.eq,
          value: id,
        },
      ],
    };
    return await data.update(input);
  },
  async remove(id: string): Promise<any> {
    let input: Delete = {
      table: table,
      criteria: [
        {
          table,
          column: "id",
          cop: COP.eq,
          value: id,
        },
      ],
    };
    return await data.delete(input);
  },
};
