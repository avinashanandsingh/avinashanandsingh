import Criteria from "../../models/criteria";
import { COP } from "../../models/enum";
import UpdateModel from "../../models/update";
class Update {
    valueType(value: any) {
        return (typeof value);
    }

    build(args: UpdateModel) {
        var table = args.table;
        var columns = args.columns;
        var params: string[] = [];
        var query: string;
        var p = 1;
        columns.forEach(x => {
            params.push(`${x} = $${p}`);
            p++;
        });
        query = `UPDATE ${table} SET ${params.join(",")}`;
        query += this.where(args.criteria, p);
        query += ` RETURNING *;`;
        return query;
    }

    cop(op: string) {
        var operator = "";
        if (op) {
            switch (op) {
                case "eq":
                    operator = "=";
                    break;
                case "ne":
                    operator = "!=";
                    break;
                case "gt":
                    operator = ">";
                    break;
                case "lt":
                    operator = "<";
                    break;
                case "ge":
                    operator = ">=";
                    break;
                case "le":
                    operator = "<=";
                    break;
                case "like":
                    operator = "ILIKE";
                    break;
            }
        }
        return operator;
    }

    condition(op: string, table: string, name: string, value: any) {
        if (table) {
            return `${table}.${name} ${this.cop(op)} ${value}`;
        } else {
            return `${name} ${this.cop(op)} ${value}`;
        }
    }
    andOr(op: string, lop: string, table: string, name: string, value: any) {
        var clause = "";
        if (table) {
            if (lop == "AND") {
                return ` AND ${table}.${name} ${this.cop(op)} ${value}`;
            } else {
                clause += ` OR ${table}.${name} ${this.cop(op)} ${value}`;
            }
        } else {
            if (lop == "AND") {
                return ` AND ${name} ${this.cop(op)} ${value}`;
            } else {
                clause += ` OR ${name} ${this.cop(op)} ${value}`;
            }
        }
        return clause;
    }
    where(criteria: Criteria[], idx: number) {
        var clause = "";
        if (criteria) {
            clause = " WHERE ";
            var param = idx;
            criteria.forEach((item: Criteria) => {
                var flag = false;
                if (item.lop) {
                    switch (item.cop) {
                        case COP.in:
                            flag = true;
                            var in_values = JSON.parse(JSON.stringify(item.value));
                            var inv: string[] = [];
                            for (var i = 0; i < in_values.length; i++) {
                                inv.push(`$${param}`);
                                param++;
                            }
                            if (item.table) {
                                clause += ` ${item.lop} ${item.table}.${item.column} IN (${inv.join(",")})`;
                            } else {
                                clause += ` ${item.lop} ${item.column} IN (${inv.join(",")})`;
                            }
                            break;
                        case COP.ni:
                            flag = true;
                            var in_values = JSON.parse(JSON.stringify(item.value));
                            var inv: string[] = [];
                            for (var i = 0; i < in_values.length; i++) {
                                inv.push(`$${param}`);
                                param++;
                            }
                            if (item.table) {
                                clause += ` ${item.lop} ${item.table}.${item.column} NOT IN (${inv.join(",")})`;
                            } else {
                                clause += ` ${item.lop} ${item.column} NOT IN (${inv.join(",")})`;
                            }
                            break;
                        default:
                            clause += this.andOr(item.cop!, item.lop!, item.table!, item.column!, `$${param}`);
                            break;
                    }
                }
                else {
                    switch (item.cop) {
                        case COP.in:
                            flag = true;
                            var in_values = JSON.parse(JSON.stringify(item.value));
                            var inv: string[] = [];
                            for (var i = 0; i < in_values.length; i++) {
                                inv.push(`$${param}`);
                                param++;
                            }
                            if (item.table) {
                                clause += `${item.table}.${item.column} IN (${inv.join(",")})`;
                            } else {
                                clause += `${item.column} IN (${inv.join(",")})`;
                            }
                            break;
                        case COP.ni:
                            flag = true;
                            var in_values = JSON.parse(JSON.stringify(item.value));
                            var inv: string[] = [];
                            for (var i = 0; i < in_values.length; i++) {
                                inv.push(`$${param}`);
                                param++;
                            }
                            if (item.table) {
                                clause += `${item.table}.${item.column} NOT IN (${inv.join(",")})`;
                            } else {
                                clause += `${item.column} NOT IN (${inv.join(",")})`;
                            }
                            break;
                        default:
                            clause += this.condition(item.cop!, item.table!, item.column!, `$${param}`);
                            break;
                    }
                }
                if (flag === false) {
                    param++;
                }
            });
        }
        return clause;
    }
}

export default Update;