import InsertModel from "../../models/insert";
class Insert {
    valueType(value: any) {
        return (typeof value);
    }
    build(args: InsertModel) {
        var table = args.table;
        var columns = args.columns.map(x=> { return x.name });
        var params: string[] = [];
        for (var p = 0; p < columns.length; p++) {
            params.push(`$${p + 1}`);
        }
        var query = `INSERT INTO ${table}(${columns.join(",")}) VALUES(${params.join(",")}) RETURNING *;`;
        //console.log(query);
        return query;
    }
}

export default Insert;