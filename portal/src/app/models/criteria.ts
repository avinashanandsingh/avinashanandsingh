import { COP, LOP } from "./enum";
export default class Criteria {
    public table?: string;
    public column?: string;
    public cop?: COP;
    public lop?: LOP;
    public value?: any;
}