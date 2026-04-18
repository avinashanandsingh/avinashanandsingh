import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import { StorageService } from './storage-service';
import Filter from '../models/filter';
import Data from '../models/data';
import { IMeditationData } from '../models/meditation';

@Injectable({
  providedIn: 'root',
})
export class MeditationService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async list(filter: Filter): Promise<Data<IMeditationData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { meditations(filter: $filter) { count rows { id title thumbnail url status courseid course{ id level } } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.meditations!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { meditation (id: $id) { id title thumbnail url status courseid course { id  level } } }',
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
      query: 'mutation delete($id: UUID!) { deleteMeditation (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
