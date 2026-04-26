import { COP } from "../models/enum";
import Filter from "../models/filter";
import Select from "../models/select";
import Update from "../models/update";

import data from "./data/index";
import Result from "../models/result";
import Delete from "../models/delete";
const table: string = "timeslots";
export default {
  get: async (id?: string): Promise<Partial<any> | null> => {
    let row: Partial<any> | null = null;
    try {
      let columns = await data.columns([{ name: table }]);
      let input: Select = {
        tables: [
          {
            name: table,
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
      row = result.rows?.shift() as Partial<any>;
    } catch (e) {}
    return row;
  },
  find: async (filter: Filter): Promise<Partial<any> | null> => {
    let row: Partial<any> | null = null;
    try {
      let columns = await data.columns([{ name: "view_users" }]);
      let input: Select = {
        tables: [
          {
            name: table,
            columns: columns.map((x: any) => {
              return { name: x.name };
            }),
          },
        ],
        ...filter,
      };
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<any>;
    } catch (e) {
      console.log(e);
    }
    return row;
  },
  filter: async (filter: Filter): Promise<Result<any> | null> => {
    let result: Result<any> | null = null;
    try {
      let columns = await data.columns([{ name: table }]);
      let input: Select = {
        tables: [
          {
            name: table,
            columns: columns.map((x: any) => {
              return { name: x.name };
            }),
          },
        ],
        criteria: filter?.criteria,
        orderBy: filter?.orderBy,
        offset: filter?.offset,
        limit: filter?.limit,
      };
      result = await data.select(input);
    } catch (e) {
      console.log(e);
    }
    return result;
  },
  async update(id: string, row: any): Promise<any> {
    let input: Update = {
      table: table,
      columns: Object.keys(row),
      values: Object.values(row),
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
  async delete(id: string): Promise<any> {
    let input: Delete = {
      table: table,
      criteria: [
        {
          table,
          column: "serviceid",
          cop: COP.eq,
          value: id,
        },
      ],
    };
    return await data.delete(input);
  },
};
