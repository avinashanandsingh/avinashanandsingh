import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { ITemplateData } from '../models/template';

@Injectable({
  providedIn: 'root',
})
export class TemplateService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}


  async typelist(): Promise<{name:string, value: string}[]> {
    let body = {
      query:
        'query list ($name: String!) { enums (name: $name) { name value } }',
      variables: {
        name: "template_type",
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.enums!;
  }

  async categorylist(): Promise<{name:string, value: string}[]> {
    let body = {
      query:
        'query list ($name: String!) { enums(name: $name) { name value } }',
      variables: {
        name: "template_category",
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.enums!;
  }

  async list(filter: Filter): Promise<Data<ITemplateData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { templates(filter: $filter) { count rows { id type category subject body createdat creator { id first_name last_name email phone } updatedat updater { id first_name last_name email phone }  } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.templates!;
  }

  async get(id: String) {
    let body = {
      query:
        'query get($id: UUID!) { referral (id: $id) { id referrer referby { id first_name last_name email phone } first_name last_name email referredat acceptedat } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: ITemplateData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: TemplateIn!) { newTemplate(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
  async update(input: ITemplateData): Promise<any> {
    let id = input.id;
    delete input.id;
    delete input.creator;
    delete input.createdat;
    delete input.updatedat;
    delete input.updater;
    let body = {
      query:
        'mutation update($id:UUID!, $input: TemplateIn!) { updateTemplate(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deleteTemplate (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
