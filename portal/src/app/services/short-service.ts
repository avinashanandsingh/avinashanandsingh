import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import { IShortData } from '../models/short';
import Filter from '../models/filter';
import { StorageService } from './storage-service';
import Data from '../models/data';

@Injectable({
  providedIn: 'root',
})
export class ShortService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async list(filter: Filter): Promise<Data<IShortData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { shorts(filter: $filter) { count rows { id title thumbnail url status likes hits createdat } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.shorts!;
  }

  async get(id: String) {
    let body = {
      query:
        'query get($id: String!) { short(id: $id) { id title thumbnail url status likes hits createdat } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
  async saveFormData(body: FormData): Promise<any> {
    //let header = this.header.api();
    let token = this.store!.get('xt');
    return await this.api.postForm(this.url, { authorization: token }, body);
  }
  async delete(id: String) {
    let body = {
      query: 'mutation delete($id: UUID!) { deleteShort (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
