import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IUser } from '../models/user';
import { StorageService } from './storage-service';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async rolelist(): Promise<{ name: string; value: string }[]> {
    let body = {
      query: 'query list ($name: String!) { enums (name: $name) { name value } }',
      variables: {
        name: 'role',
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.enums!;
  }

  async list(filter: Filter): Promise<Data<IUser>> {
    let body = {
      query:
        'query list ($filter: Filter!) { users(filter: $filter) { count rows { id role first_name last_name email phone countryid country { id name } stateid state { id, name } cityid city { id name } avatar status createdat creator { id first_name last_name email phone } updatedat updater { id first_name last_name email phone } referby { id first_name last_name email phone } } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.users!;
  }

  async get(id: String) {
    let body = {
      query:
        'query get($id: UUID!) { user (id: $id) { id role first_name last_name email phone countryid stateid cityid avatar status profession income createdat creator { id first_name last_name email phone } updatedat updater { id first_name last_name email phone } } }',
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
      query: 'mutation delete($id: UUID!) { deleteTemplate (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
