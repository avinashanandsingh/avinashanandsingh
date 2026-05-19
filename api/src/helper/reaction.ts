import { COP } from "../models/enum";
import Filter from "../models/filter";
import Select from "../models/select";
import Update from "../models/update";
import User from "../models/user";
import data from "./data/index";
import Result from "../models/result";
import Insert from "../models/insert";
import date from "./date";
import Criteria from "../models/criteria";
const table: string = "reactions";
const view: string = "view_reactions";
export default {
  count: async (criteria: Criteria[]): Promise<number | null> => {
    let count: number | null = null;
    try {
      
      let counter = {
        table: view,
        criteria: criteria,
      };
      count = await data.count(counter);
    } catch (e) {
      console.log(e);
    }
    return count;
  },
  get: async (id?: string): Promise<Partial<any> | null> => {
    let row: Partial<User> | null = null;
    try {
      let columns = await data.columns([{ name: view }]);
      let input: Select = {
        tables: [
          {
            name: view,
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
      row = result.rows?.shift() as Partial<User>;
    } catch (e) {}
    return row;
  },
  find: async (filter: Filter): Promise<Partial<any> | null> => {
    let row: Partial<any> | null = null;
    try {
      let columns = await data.columns([{ name: view }]);
      let input: Select = {
        tables: [
          {
            name: view,
            columns: columns.map((x: any) => {
              return { name: x.name };
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
  filter: async (filter: Filter): Promise<Result<any> | null> => {
    let result: Result<any> | null = null;
    try {
      let columns = await data.columns([{ name: view }]);
      let input: Select = {
        tables: [
          {
            name: view,
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
  
  async add(row: any): Promise<any> {
    let columns = Object.keys(row).map((x) => {
      return {
        name: x,
      };
    });
    let input: Insert = {
      table: table,
      columns: columns,
    };
    input.columns.push({name: "createdat" });
    let values = Object.values(row);
    values.push(date.utcTimeStamp());

    return await data.insert(input, values);
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
