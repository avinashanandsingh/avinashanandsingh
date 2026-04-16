import Criteria from "./criteria";

export default class Delete {
    public table: string;
    public criteria: Criteria[];
    constructor(table: string, criteria: Criteria[]) {
        this.table = table;
        this.criteria = criteria;
    }
}