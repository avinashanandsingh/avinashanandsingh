import { COP } from "../models/enum";
import Filter from "../models/filter";
import Select from "../models/select";
import data from "./data/index";
import Result from "../models/result";
const view: string = "view_schedules";
export default {
  get: async (id?: string): Promise<Partial<any> | null> => {
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
        criteria: [
          {
            table: view,
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
      row = result.rows?.shift() as Partial<any>;
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
};
