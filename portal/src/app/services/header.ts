import { Injectable } from '@angular/core';
import { StorageService } from './storage-service';

@Injectable({
  providedIn: 'root',
})
export class Header {
  constructor(private store: StorageService) {}
  api():any {
    let token = this.store!.get('xt');
    let header:any = {
      'Content-Type': 'application/json; charset=utf8;',
    };
    if (token !== null) {
      header = {
        'Content-Type': 'application/json; charset=utf8;',
        //'x-source': source,
        //'x-api-key': data.xkey,
        //'x-api-secret': data.xsecret,
        authorization: token,
      };
    }
    return header;
  }
}
