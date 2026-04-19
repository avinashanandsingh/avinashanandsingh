import Select from "../models/select";
import ISmtpData from "../models/smtp";
import data from "./data/index";

const table: string = "smtps";
export default {
  get: async (): Promise<Partial<ISmtpData> | null> => {
    let row: Partial<ISmtpData> | null = null;
    try {
      let columns = await data.columns([{ name: table }]);
      let input: Select = {
        tables: [
          {
            name: table,
            columns: columns,
          },
        ],
      };
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<ISmtpData>;
    } catch (e) {}
    return row;
  },
};
