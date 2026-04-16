import City from "../models/city";
import { COP } from "../models/enum";
import Result from "../models/result";
import Select from "../models/select";
import data from "./data/index";
export default {
  cityList: async (country?: string): Promise<City[] | null> => {
    let result: Result<City> | null = null;    
    let table: string = "view_cities";
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
      };
      if (country) {
        input.criteria!.push({
          column: "country",
          cop: COP.eq,
          value: country,
        });
      }
      result = await data.select(input);
    } catch (e) {}
    return result?.rows!;
  },
};
