import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IPageData } from '../models/page';
import { ISettingData } from '../models/setting';

@Injectable({
  providedIn: 'root',
})
export class SettingService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async list(filter: Filter): Promise<Data<ISettingData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { settings(filter: $filter) { count rows { id name value createdat creator { id first_name last_name email phone } updatedat updater { id first_name last_name email phone }  } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.settings!;
  }

  async get(key?: String) {
    let body = {
      query:
        'query get($filter: Filter!) { setting (filter: $filter) { id name value creator { first_name last_name email phone } updater { first_name last_name email phone } } }',
      variables: {
        filter: {
          criteria: [
            {
              column: 'name',
              cop: 'eq',
              value: key,
            },
          ],
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: ISettingData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: SettingIn!) { newSetting(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
  async update(input: ISettingData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:UUID!, $input: SettingIn!) { updateSetting(id: $id, input: $input) { id } }',
      variables: {
        id: id,
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async delete(id: String) {
    let body = {
      query: 'mutation delete($id: UUID!) { deleteSetting (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
