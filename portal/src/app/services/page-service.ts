import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IPageData } from '../models/page';

@Injectable({
  providedIn: 'root',
})
export class PageService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async typelist(): Promise<{ name: string; value: string }[]> {
    let body = {
      query: 'query list ($name: String!) { enums (name: $name) { name value } }',
      variables: {
        name: 'page_type',
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.enums!;
  }

  async list(filter: Filter): Promise<Data<IPageData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { pages(filter: $filter) { count rows { id type title body createdat creator { id first_name last_name email phone } updatedat updater { id first_name last_name email phone }  } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.pages!;
  }

  async get(id?: String, type?: String) {
    let body = {
      query:
        'query get($filter: PageFilter!) { page (filter: $filter) { id type title body creator { first_name last_name email phone } updater { first_name last_name email phone } } }',
      variables: {
        filter: {
          id: id,
          type: type,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: IPageData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: PageIn!) { newPage(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
  async update(input: IPageData): Promise<any> {
    let id = input.id;
    delete input.id;
    delete input.creator;
    delete input.createdat;
    delete input.updatedat;
    delete input.updater;
    let body = {
      query:
        'mutation update($id:UUID!, $input: PageIn!) { updatePage(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deletePage (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
