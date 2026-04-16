import pgql from "./pgql";
export default async (table: string): Promise<any[]> => {
  let list: object[] = [];
  try {
    let query = "select * from view_columns WHERE table_name = $1";
    let result = await pgql.read(query, [table]);
    if (result !== undefined) {
      list = result.rows;
    }
  } catch (e) {
    throw e;
  }
  return list;
};
