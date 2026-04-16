import { COP, LOP } from "../models/enum";
import Filter from "../models/filter";
import Insert from "../models/insert";
import Message from "../models/message";
import Result from "../models/result";
import Select from "../models/select";
import Update from "../models/update";
import data from "./data/index";
const table: string = "messages";
export default {
  get: async (id?: number): Promise<Partial<Message> | null> => {
    let row: Partial<Message> | null = null;
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
      console.log("message.get.input: ", input);
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<Message>;
    } catch (e) {
      throw e;
    }
    return row;
  },
  me: async (
    code?: number,
    lang: string = "EN",
  ): Promise<Partial<Message> | null> => {
    let row: Partial<Message> | null = null;
    try {
      let input: Select = {
        tables: [
          {
            name: table,
            columns: [{ name: "type" }, { name: "code" }, { name: "message" }],
          },
        ],
        criteria: [
          {
            table,
            column: "code",
            cop: COP.eq,
            value: code,
          },
          {
            table,
            column: "language",
            lop: LOP.AND,
            cop: COP.eq,
            value: lang,
          },
        ],
      };
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<Message>;
    } catch (e) {
      throw e;
    }
    return row;
  },
  find: async (filter: Filter): Promise<Partial<Message> | null> => {
    let row: Partial<Message> | null = null;
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
        ...filter,
      };
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<Message>;
    } catch (e) {
      throw e;
    }
    return row;
  },
  filter: async (filter: Filter): Promise<Result<Message> | null> => {
    let result: Result<Message> | null = null;
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
        criteria: filter.criteria,
        orderBy: filter.orderBy,
        offset: filter.offset,
        limit: filter.limit,
      };
      result = await data.select(input);
    } catch (e) {}
    return result;
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

  async add(row: any): Promise<any> {
    try {
      let input: Insert = {
        table: table,
        columns: Object.keys(row).map((x) => {
          return { name: x };
        }),
      };
      let values = Object.values(row);
      let result = await data.insert(input, values);
      return result;
    } catch (e: any) {
      console.log("message.add.error: ", e.message);
      throw e;
    }
  },
  async latest(): Promise<Partial<Message> | null> {
    let row: Partial<Message> | null = null;
    let tableName: string = "view_latest_message";
    try {
      let columns = await data.columns([{ name: tableName }]);
      let input: Select = {
        tables: [
          {
            name: tableName,
            columns: columns.map((x: any) => {
              return { name: x.name };
            }),
          },
        ],
      };
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<Message>;
    } catch (e) {
      console.log("message.latest.error:", e);
    }
    return row;
  },
};
