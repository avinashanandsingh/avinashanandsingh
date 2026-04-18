import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class StorageService {
  constructor() {}
  public set(key: string, value: string) {
    localStorage.setItem(key, value);
  }
  public get(key: string) {
    let value: any = '';
    if (typeof localStorage !== 'undefined') {
      value = localStorage.getItem(key);
    }
    return value;
  }
  public remove(key: string) {
    localStorage.removeItem(key);
  }
  public clear() {
    localStorage.clear();
  }
}
