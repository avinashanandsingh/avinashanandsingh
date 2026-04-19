import { COP } from "../models/enum";
import Select from "../models/select";
import data from "./data/index";
const table: string = "view_enums";
export default {
  list: async (
    name: string,
  ): Promise<Partial<{ name: string; value: string }>[] | null> => {
    let rows: Partial<{ name: string; value: string }>[] | null = null;
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
            column: "name",
            cop: COP.eq,
            value: name,
          },
        ],
      };
      let result = await data.select(input);
      rows = result.rows as Partial<{ name: string; value: string }>[];
    } catch (e) {}
    return rows;
  },
};
