import Column from "./column";

export default class Insert {
  public table: string;
  public columns: Column[];

  constructor(table: string, columns: Column[]) {
    this.table = table;
    this.columns = columns;
  }
}
