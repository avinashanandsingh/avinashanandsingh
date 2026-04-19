import { COP, LOP } from "../models/enum";
import Select from "../models/select";
import ITemplateData from "../models/template";
import data from "./data/index";

const table: string = "templates";
export default {
  get: async (
    type: string,
    category: string,
  ): Promise<Partial<ITemplateData> | null> => {
    let row: Partial<ITemplateData> | null = null;
    try {
      let columns = await data.columns([{ name: table }]);
      let input: Select = {
        tables: [
          {
            name: table,
            columns: columns,
          },
        ],
        criteria: [
          {
            column: "type",
            cop: COP.eq,
            value: type,
          },
          {
            column: "category",
            cop: COP.eq,
            lop: LOP.AND,
            value: category,
          },
        ],
      };
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<ITemplateData>;
    } catch (e) {}
    return row;
  },
};
