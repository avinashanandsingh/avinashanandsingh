import db from "./pgql";
import Select from "./select";
import Insert from "./insert";
import Update from "./update";
import Delete from "./delete";
import Distinct from "./distinct";
import SelectModel from "../../models/select";
import InsertModal from "../../models/insert";
import UpdateModel from "../../models/update";
import DeleteModal from "../../models/delete";
import Table from "../../models/table";
import { QueryResult } from "pg";
import Result  from "../../models/result";
//const letters = new RegExp(/^[_a-zA-Z0-9]+$/);
class Data {
  public Distinct: Distinct = new Distinct();
  public Select: Select = new Select();
  public Insert: Insert = new Insert();
  public Update: Update = new Update();
  public Delete: Delete = new Delete();

  async raw(query: string, values: any[]) {
    let rows = [];
    try {
      let result = await db.read(query, values);

      if (result.rows.length > 0) {
        rows = result.rows;
      }
      return rows;
    } catch (e) {
      throw e;
    }
  }

  async tables() {
    let query = "SELECT table_name as name FROM information_schema.tables";
    let rows = [];
    try {
      let result = await db.read(query, []);

      if (result.rows.length > 0) {
        rows = result.rows.map((item) => {
          return item.name;
        });
      }
      return rows;
    } catch (e) {
      throw e;
    }
  }

  async columns(tables: Table[]) {
    let tbls: string[] = [];
    let rows = [];
    tables.forEach((table) => {
      tbls.push(`'${table.name}'`);
    });

    var query = `SELECT table_name as table, column_name as name, data_type as type, character_octet_length length, is_nullable nullable FROM information_schema.columns WHERE table_name IN(${tbls.join(
      ","
    )})`;
    try {
      let result = await db.read(query, []);
      if (result.rows.length > 0) {
        rows = result.rows.map((item) => {
          return item;
        });
      }
      return rows;
    } catch (e) {
      throw e;
    }
  }

  async foreignkeys(table: string) {
    var query = `SELECT tc.table_name, tc.constraint_type, kcu.column_name, ccu.table_name AS foreign_table_name, ccu.column_name AS foreign_column_name FROM information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name='${table}' AND tc.table_schema='public'`;
    try {
      console.log(query);
      let result = await db.read(query, []);
      return result.rows.map((item) => {
        return item;
      });
    } catch (err) {
      throw err;
    }
  }
  async select<T>(args: SelectModel): Promise<Result<T>> {
    let result: Result<T> | null = null;
    let query: string = this.Select.build(args);
    let from = query.substring(query.indexOf("FROM")).trim();
    let count = from;
    if(query.indexOf("ORDER BY") > -1) {
      count = from.substring(0, from.indexOf("ORDER BY")-1).trim();
    } else if(query.indexOf("LIMIT") > -1) {
      count = from.substring(0, from.indexOf("LIMIT")-1).trim();
    }
        
     query = `SELECT json_build_object(
      'count', (SELECT count(1) ${count}),
      'rows', json_agg(x)
    ) data
    FROM (${query}) x;`;    
    
    delete args["groupBy"];
    const values: any[] = [];
    if (args?.criteria !== undefined) {
      this.extact(args?.criteria, values);
    }
    let tables = args.tables;
    //let columns = await this.columns(args.tables!);
    let queryColumns: any[] = [];
    tables?.forEach((table?: Table) => {
      table?.columns?.forEach((column) => {
        queryColumns.push({
          table: table.name,
          name: column.name,
          alias: column.alias,
        });
      });
    });    
    try {
      let data = await db.read(query, values);    
      result = data?.rows?.shift().data;      
    } catch (e) {
      throw e;
    }
    return result as Result<T> || null;
  }

  async distinct<T>(args: any): Promise<Result<T> | null> {
    let data: Result<T> | null = null;
    var query: string = this.Distinct.build(args);
    let from = query.substring(query.indexOf("FROM")).trim();
    let count ="";
    if(query.indexOf("ORDER BY") > -1) {
      count = from.substring(0, from.indexOf("ORDER BY")-1).trim();
    } else if(query.indexOf("LIMIT") > -1) {
      count = from.substring(0, from.indexOf("LIMIT")-1).trim();
    }
        
     query = `SELECT json_build_object(
      'count', (SELECT count(1) ${count}),
      'rows', json_agg(x)
    ) data
    FROM (${query}) x;`;    
    
    delete args.input["groupBy"];
    const values: any[] = [];
    this.extactValues(args.criteria, values);
    let tables = args.input.tables;
    let columns = await this.columns(tables);
    let queryColumns: any[] = [];
    tables.forEach((table: any) => {
      table.columns.forEach((column: any) => {
        queryColumns.push({
          table: table.name,
          name: column.name,
          alias: column.alias,
        });
      });
    });

    var rows: any[] = [];
    try {
      let result = await db.read(query, values);
      data = result?.rows?.shift().data;
      /* result.rows.forEach((item) => {
        var keys = Object.keys(item);
        keys.forEach((x) => {
          var column = queryColumns.find((c) => {
            return c.name === x || (c.alias !== undefined && c.alias === x);
          });
          var tbl_col = columns.find((c) => {
            return c.name === column.name && c.table === column.table;
          });
          if (
            tbl_col.type === "bigint" ||
            tbl_col.type === "integer" ||
            tbl_col.type === "real" ||
            tbl_col.type === "numeric"
          ) {
            item[x] = Number(item[x]);
          } else if (tbl_col.type === "boolean") {
            item[x] = Boolean(item[x]);
          }
        });
        rows.push(item);
      });
      return rows; */      
    } catch (e) {
      throw e;
    }
    return data as Result<T> || null;
  }

  async count(args: any) {
    var sql = `SELECT COUNT(1) FROM ${args.table}`;
    const values: any[] = [];
    if (args.criteria !== undefined) {
      sql += this.Select.where(args.criteria);
      this.extactValues(args.criteria, values);
    }
    let result = await db.read(sql, values);
    return result.rows[0].count;
  }

  async min(args: any) {
    var sql = `SELECT MIN(${args.column}) FROM ${args.table}`;
    sql += this.Select.where(args.criteria);
    const values: any[] = [];
    this.extactValues(args.criteria, values);
    let result = await db.read(sql, values);
    return result.rows.shift().min;
  }

  async max(args: any) {
    var sql = `SELECT MAX(${args.column}) FROM ${args.table}`;
    sql += this.Select.where(args.criteria);
    const values: any[] = [];
    this.extactValues(args.criteria, values);
    let result = await db.read(sql, values);
    return result.rows.shift().max;
  }

  async sum(args: any) {
    let sql = `SELECT SUM(${args.column}) FROM ${args.table}`;
    sql += this.Select.where(args.criteria);
    const values: any[] = [];
    this.extactValues(args.criteria, values);
    let result = await db.read(sql, values);
    return result.rows.shift().sum;
  }

  async avg(args: any) {
    let sql = `SELECT AVG(${args.column}) FROM ${args.table}`;
    sql += this.Select.where(args.criteria);
    const values: any[] = [];
    this.extactValues(args.criteria, values);
    let result = await db.read(sql, values);
    return result.rows.shift().avg;
  }

  async insert(args: InsertModal, values: any[]): Promise<any> {
    var query = this.Insert.build(args);
    let row: any;
    try {
      let result = await db.write(query, values);      
      if (result !== undefined) {
        row = result?.rows?.shift();
      }
    } catch (e) {
      throw e;
    }
    return row;
  }

  async update(args: UpdateModel): Promise<any> {
    let rows: any[] = [];
    let row: any;
    var query = this.Update.build(args);
    const values = args.values!;
    this.extact(args.criteria, values);
    try {
      let result: any = await db.write(query, values);
      let table: Table = new Table();
      table.name = args.table;
      let tables: Table[] = [table];
      let columns = await this.columns(tables);      
      if (result?.rowCount > 0) {
        result?.rows.forEach((item: any) => {
          var keys = Object.keys(item);
          keys.forEach((x) => {
            var tbl_col = columns.find((c) => {
              return c.name === x;
            });
            if (
              tbl_col.type === "bigint" ||
              tbl_col.type === "integer" ||
              tbl_col.type === "real" ||
              tbl_col.type === "numeric"
            ) {
              item[x] = Number(item[x]);
            } else if (tbl_col.type === "boolean") {
              item[x] = Boolean(item[x]);
            }
          });
          rows.push(item);
        });
        row = rows.shift();
      }
    } catch (e) {
      throw e;
    }
    return row;
  }

  async delete(args: any) {
    var query = this.Delete.build(args);
    const values: any[] = [];
    this.extactValues(args.criteria, values);
    try {
      let result: QueryResult = await db.write(query, values);
      if (result?.rowCount! > 0) {
        return result.rows.shift();
      }
    } catch (e) {
      throw e;
    }
  }

  async simple(args: any) {
    var inserts = args.insert;
    var updates = args.update;
    var deletes = args.delete;

    var queries: any[] = [];
    if (inserts) {
      inserts.forEach((item: InsertModal) => {
        var query = {
          table: item.table,
          query: this.Insert.build(item),
          values: [],
        };
        const values: any[] = [];
        this.extactValues(item, values);
        query["values"] = values as [];
        queries.push(query);
      });
    }
    if (updates) {
      updates.forEach((item: UpdateModel) => {
        var query = {
          table: item.table,
          query: this.Update.build(args),
          values: [],
        };
        const values: any[] = [];
        this.extactValues(item, values);
        query.values = values as [];
        queries.push(query);
      });
    }
    if (deletes) {
      deletes.forEach((item: DeleteModal) => {
        var query = {
          table: item.table,
          query: this.Delete.build(item),
          values: [],
        };
        const values: any[] = [];
        this.extactValues(item, values);
        query.values = values as [];
        queries.push(query);
      });
    }

    var result = [];
    try {
      await db.write("BEGIN", []);
      result = await Promise.all(
        queries.map(async (item) => {
          if (item.values) {
            let res = await db.write(item.query, item.values);
            return {
              type: res.command,
              table: item.table,
              content: res.rows[0],
            };
          } else {
            let res = await db.write(item.query, []);
            return {
              type: res.command,
              table: item.table,
              content: res.rows[0],
            };
          }
        })
      );
      await db.write("COMMIT", []);
    } catch (e) {
      await db.write("ROLLBACK", []);
      throw e;
    }
    return result;
  }

  async complex(args: any) {
    try {
      await db.write("BEGIN", []);
      this.executeRecursively(args, undefined);
      await db.write("COMMIT", []);
    } catch (e) {
      await db.write("ROLLBACK", []);
      throw e;
    }
    //console.log(result.rows);
    //return result;
  }

  async executeRecursively(input: any, val: any) {
    /* var query,
      values = [],
      res,
      fks;
    if (input.complex) {
      if (input.insert) {
        if (val) {
          fks = this.fkeys(val.table);
          fks.forEach((key) => {
            input.insert.columns.push(key.column_name);
            input.insert.values.push(val.content.id);
          });
        }
        
        query = this.Insert.build(input.insert);
        values = input.insert.values;
        //res = await client.query(query, values);
      } else if (input.update) {
        if (val) {
          fks = this.fkeys(val.table);
          fks.forEach((key) => {
            input.insert.columns.push(key.column_name);
            input.insert.values.push(val.content.id);
          });
        }
        var args = {
          input: input.insert,
        };
        query = Insert.build(args);
        values = input.insert.values;
        res = await client.query(query, values);
      } else if (input.delete) {
        query = Delete.build(args);
        res = await client.query(query);
      }
      return executeRecursively(input.complex, {
        type: res.command,
        table: item.table,
        content: res.rows[0],
      });
    } else {
      if (input.insert) {
        query = Insert.build(args);
        values = input.insert.values;
        res = await db.write(query, values);
      } else if (input.update) {
        query = Update.build(args);
        values = input.insert.values;
        res = await db.write(query, values);
      } else if (input.delete) {
        query = Delete.build(args);
        res = await db.write(query);
      }
      return { type: res.command, table: item.table, content: res.rows[0] };
    } */
  }
  extact(input: any, ref: any[]): void {
    var keys = Object.keys(input);
    keys.forEach((key: any) => {
      if (typeof input[key] == "object") {
        this.extact(input[key], ref);
      } else {
        if (key === "value" || key === "values") {
          //return ;
          ref.push(input[key]);
        } else {
          if (Number(key) >= 0) {
            //return input[key];
            ref.push(input[key]);
          }
        }
      }
    });
  }

  extactValues(args: any, ref: any[]): void {
    var values = this.extact(args, ref);
    /* var values = new JefNode(values_from_schema).filter(function (node: any) {
      var value;
      switch (node.type()) {
        case "number":
          value = node.value;
          break;
        case "boolean":
          value = node.value;
          break;
        case "string":
          value = node.value;
          break;
      }
  
      return value;
    }); */
    return values;
  }
}
export default new Data();
