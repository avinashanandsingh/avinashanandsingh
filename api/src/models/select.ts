import Join from "./join";
import Table from "./table";
import Criteria from "./criteria";
import OrderBy from "./orderby";
import GroupBy from "./groupby";

export default class Select {
    public tables?: Table[];
    public joins?: Join[];
    public criteria?: Criteria[];
    public orderBy?: OrderBy[];
    public groupBy?: GroupBy[];
    public offset?: number;
    public limit?: number;
}