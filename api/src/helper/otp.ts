import { COP, LOP } from "../models/enum";
import Select from "../models/select";
import Delete from "../models/delete";
import data from "./data/index";
import User from "../models/user";
export default {
  generate: (length: number = 6): string => {
    const digits: string = "0123456789";
    let otp: string = "";
    for (let i = 0; i < length; i++) {
      otp += digits[Math.floor(Math.random() * 10)];
    }
    return otp;
  },
  active: async (userId: string): Promise<Partial<any> | null> => {
    let row: Partial<any> | null = null;
    try {
      let table = "password_resets";
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
            column: "userid",
            cop: COP.eq,
            value: userId,
          },
          {
            table,
            column: "used",
            cop: COP.eq,
            lop: LOP.AND,
            value: false,
          },
        ],
      };
      let result = await data.select<any>(input);
      row = result.rows?.shift()!;
    } catch (e) {
      throw e;
    }
    return row;
  },
  verify: async (otp?: string): Promise<Partial<User> | null> => {
    let row: Partial<User> | null = null;
    try {
      let table = "password_resets";
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
            column: "otp",
            cop: COP.eq,
            value: otp,
          },
          {
            table,
            column: "used",
            cop: COP.eq,
            lop: LOP.AND,
            value: false,
          },
        ],
      };
      let result = await data.select(input);
      row = result.rows?.shift()!;
    } catch (e) {
      throw e;
    }
    return row;
  },
  delete: async (otp?: string): Promise<any> => {
    let row: any;
    try {
      let table = "password_resets";
      let input: Delete = {
        table: table,
        criteria: [
          {
            table,
            column: "otp",
            cop: COP.eq,
            value: otp,
          },
        ],
      };
      row = await data.delete(input);
    } catch (e) {}
    return row;
  },
};
