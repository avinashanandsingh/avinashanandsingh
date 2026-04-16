import Select from "../models/select";
import Result from "../models/result";
import data from "./data/index";

export default {
  get: async <T>(inupt: Select): Promise<Partial<T> | null> => {
    let row: Partial<T> | null = null;
    try {
      let result = await data.select(inupt);
      result = result.rows?.shift() as Partial<T>;
    } catch (e) {
      console.log(e);
    }
    return row;
  },
  find: async <T>(input: Select): Promise<Partial<T> | null> => {
    let row: Partial<T> | null = null;
    try {
      let result = await data.select(input);
      row = result.rows?.shift() as Partial<T>;
    } catch (e) {
      console.log(e);
    }
    return row;
  },
  filter: async <T>(input: Select): Promise<Result<T> | null> => {
    let result: Result<T> | null = null;
    try {
      result = await data.select(input);
    } catch (e) {
      console.log(e);
    }
    return result;
  },
};
