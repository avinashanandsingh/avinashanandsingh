import { COP } from "../models/enum";
import Filter from "../models/filter";
import Select from "../models/select";
import Update from "../models/update";
import User from "../models/user";
import data from "./data/index";
import Result from "../models/result";
const table: string = "users";
export default {
  hasEmail: (username?: string) => {
    const pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    let flag = pattern.test(username!);
    return flag;
  },
  hasPhone: (username?: string) => {
    const pattern = /^[+]{1}(?:[0-9\-\(\)\/.]\s?){6,15}[0-9]{1}$/;
    let flag = pattern.test(username!);
    return flag;
  },

  get: async (id?: number): Promise<Partial<User> | null> => {
    let row: Partial<User> | null = null;
    try {
      let columns = await data.columns([{ name: "view_users" }]);
      let input: Select = {
        tables: [
          {
            name: "view_users",
            columns: columns.map((x: any) => {
              return {
                name: x.name,
                value: x.value,
                alias: x.alias,
                function: x.function,
              };
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
      row = result.rows?.shift() as Partial<User>;
    } catch (e) {}
    return row;
  },
  find: async <User>(filter: Filter): Promise<Partial<User> | null> => {
    let row: Partial<User> | null = null;
    try {
      let columns = await data.columns([{ name: "view_users" }]);
      let input: Select = {
        tables: [
          {
            name: "view_users",
            columns: columns.map((x: any) => {
              return {
                name: x.name,
                value: x.value,
                alias: x.alias,
                function: x.function,
              };
            }),
          },
        ],
        ...filter,
      };
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<User>;
    } catch (e) {
      console.log(e);
    }
    return row;
  },
  filter: async (filter: Filter): Promise<Result<User> | null> => {
    let result: Result<User> | null = null;
    try {
      let columns = await data.columns([{ name: "view_users" }]);
      let input: Select = {
        tables: [
          {
            name: "view_users",
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
};
