import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IBrandingData } from '../models/branding';
import { StorageService } from './storage-service';


@Injectable({
  providedIn: 'root',
})
export class BrandingService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private store: StorageService,
    private header: Header,
  ) {}


  async typelist(): Promise<{name:string, value: string}[]> {
    let body = {
      query:
        'query list ($name: String!) { enums (name: $name) { name value } }',
      variables: {
        name: "content_type",
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.enums!;
  }

  async list(filter: Filter): Promise<Data<IBrandingData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { brandings(filter: $filter) { count rows { id type title url content createdat creator { id first_name last_name email phone } updatedat updater { id first_name last_name email phone }  } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.brandings!;
  }

  async get(id: String) {
    let body = {
      query:
        'query get($id: UUID!) { branding (id: $id) { id type title url content creator { id first_name last_name email phone } updater { id first_name last_name email phone } } }',
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
      query: 'mutation delete($id: UUID!) { deleteBranding (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
