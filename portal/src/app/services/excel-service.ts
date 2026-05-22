import { Injectable } from '@angular/core';
import * as ExcelJS from "exceljs";
@Injectable({
  providedIn: 'root',
})
export class ExcelService {
  constructor() {}
  async read(fileData: any): Promise<any[]> {
    const list: any[] = [];
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(fileData);
    const sheet = workbook.worksheets[0];
    sheet.eachRow({ includeEmpty: true }, (row, rownum) => {
      if (rownum > 1) {
        const values = row.values as any[];
        if(values.filter((x:any)=>x === undefined).length !== values.length)
        list.push(values);
      }
    });
    return list;
  }
  async write(struct:any, data?:any[]):Promise<any>{
    const workbook = new ExcelJS.Workbook();
    const sheet  = workbook.addWorksheet("Data");
    workbook.properties.date1904 = true;
    sheet.columns = struct;
    /* const alpha:string[] =['A','B','C', 'D','E','F','G','H','I','J','K','L','M', 'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
    for(let idx in struct){
      console.log(idx);
      if(Number(idx) < 26){
        sheet.getCell(`${alpha[idx]}1`).style = { font: { bold: true }};
      } else {
        let sidx = Number(idx) - 26;
        sheet.getCell(`${alpha[idx]}${alpha[sidx]}1`).style = { font: { bold: true }};
      }
    } */
    data?.forEach(x=>{
      sheet.addRow(x);
    })
    
    const buffer:any = await workbook.xlsx.writeBuffer();
    return buffer;
  }
}
