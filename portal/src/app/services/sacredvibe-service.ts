import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import { StorageService } from './storage-service';
import Filter from '../models/filter';
import Data from '../models/data';
import { IScarevibeData } from '../models/scarevibe';

@Injectable({
  providedIn: 'root',
})
export class SacredvibeService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async list(filter: Filter): Promise<Data<IScarevibeData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { sacredvibes (filter: $filter) { count rows { id title url duration status } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.sacredvibes!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { sacredvibe (id: $id) { id title url status } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async save(body: FormData): Promise<any> {
    //let header = this.header.api();
    let token = this.store!.get('xt');
    return await this.api.postForm(this.url, { authorization: token }, body);
  }

  async delete(id: String) {
    let body = {
      query: 'mutation delete($id: UUID!) { deleteSacredvibe (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
