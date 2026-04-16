import Criteria from "../../models/criteria";
import { COP, LOP } from "../../models/enum";
import OrderBy from "../../models/orderby";
import SelectModel from "../../models/select";
import Table from "../../models/table";
class Select {
    valueType(value: any) {
        return (typeof value);
    }

    build(args: SelectModel): string {
        var query = "";
        var column_list: string[] = [];
        var table_list: string[] = [];
        var join_list: string[] = [];
        let tables = args.tables;
        let joins = args.joins;
        if (tables!.length > 0) {
            tables?.forEach((table?: Table) => {
                table_list.push(table?.name!);
                var columns = table?.columns;
                columns?.forEach((column) => {
                    if (column.alias) {
                        if (column.function) {
                            column_list.push(`${column.function}(${table?.name}.${column.name}) as ${column.alias}`);
                        } else {
                            column_list.push(`${table?.name}.${column.name} as ${column.alias}`);
                        }
                    } else {
                        if (column.function) {
                            column_list.push(`${column.function}(${table?.name}.${column.name}) as ${column.name}`);
                        } else {
                            column_list.push(`${table?.name}.${column.name}`);
                        }
                    }
                });
            });

            if (joins) {
                joins.forEach((item) => {
                    join_list.push(`${item.from?.table} as ${item.from?.table} `);
                    item.to?.forEach(x => {
                        switch (x.type) {
                            case "CROSS":
                                join_list.push(` CROSS JOIN ${x.table} as ${x.table}`);
                                break;
                            case "INNER":
                                join_list.push(` INNER JOIN ${x.table} as ${x.table} 
                                ON ${item.from?.table}.${item.from?.column} = ${x.table}.${x.column}`);
                                break;
                            case "LEFT_OUTER":
                                join_list.push(` LEFT OUTER JOIN ${x.table} as ${x.table} 
                                ON ${item.from?.table}.${item.from?.column} = ${x.table}.${x.column}`);
                                break;
                            case "RIGHT_OUTER":
                                join_list.push(` RIGHT OUTER JOIN ${x.table} as ${x.table} 
                                ON ${item.from?.table}.${item.from?.column} = ${x.table}.${x.column}`);
                                break;
                            case "FULL_OUTER":
                                join_list.push(` FULL OUTER JOIN ${x.table} as ${x.table} 
                                ON ${item.from?.table}.${item.from?.column} = ${x.table}.${x.column}`);
                                break;
                        }
                    });
                });
            }
        } else {
            throw Error("Column(s) not provided!");
        }
        if (join_list.length > 0) {
            query = `SELECT ${column_list.join(",")} FROM ${join_list.join(" ")}`;
        } else {
            query = `SELECT ${column_list.join(",")} FROM ${table_list.join(",")}`;
        }

        query += this.where(args.criteria);
        query += this.order(args.orderBy);
        if (args.groupBy) {
            var group = args.groupBy;
            var groups: string[] = [];
            group.forEach(g => {
                groups.push(`${g.table}.${g.column}`)
            })
            query += ` GROUP BY ${groups.join(",")}`;
        }

        let offset = args.offset;
        let limit = args.limit;
        if (limit) {
            query += ` LIMIT ${limit}`;
        }

        if (offset) {
            query += ` OFFSET ${offset}`;
        }
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
    andOr(op: COP, lop: LOP, table: string, name: string, value: any) {
        if (table) {
            if (lop == "AND") {
                return ` AND ${table}.${name} ${this.cop(op)} ${value}`;
            } else {
                return ` OR ${table}.${name} ${this.cop(op)} ${value}`;
            }
        } else {
            if (lop == "AND") {
                return ` AND ${name} ${this.cop(op)} ${value}`;
            } else {
                return ` OR ${name} ${this.cop(op)} ${value}`;
            }
        }
    }
    where(criteria?: Criteria[]) {
        var clause = "";
        if (criteria && criteria.length > 0) {
            clause = " WHERE ";
            var param = 1;
            criteria.forEach((item: Criteria) => {
                var flag = false;
                if (item.lop) {
                    if (item.cop == "in") {
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
                    } else if (item.cop == "ni") {
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
                    } else {
                        clause += this.andOr(item.cop!, item.lop!, item.table!, item.column!, `$${param}`);
                    }
                }
                else {
                    if (item.cop == "in") {
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
                    } else if (item.cop == "ni") {
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
                    } else {
                        clause += this.condition(item.cop!, item.table!, item.column!, `$${param}`);
                    }
                }
                if (flag === false) {
                    param++;
                }
            });
        }
        return clause;
    }
    order(order?: OrderBy[]) {
        var clause = "";
        if (order) {
            clause = " ORDER BY ";
            var orderby: string[] = [];
            for (var idx = 0; idx < order.length; idx++) {
                var item: OrderBy = order[idx];
                if (item.asc) {
                    orderby.push(`${item.column} ASC `)
                } else {
                    orderby.push(`${item.column} DESC `)
                }
            }
            clause += `${orderby.join(",")} `
        }
        return clause;
    }
}
export default Select;