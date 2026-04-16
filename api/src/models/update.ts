import Criteria from "./criteria";

export default class Update {
    public table: string;
    public columns: string[];
    public criteria: Criteria[];
    public values?: any[];
    constructor(table: string, columns: string[], criteria: Criteria[]) {
        this.table = table;
        this.columns = columns;
        this.criteria = criteria;
    }
}