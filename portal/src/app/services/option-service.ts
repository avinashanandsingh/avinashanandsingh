import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IOptionData } from '../models/question';

@Injectable({
  providedIn: 'root',
})
export class OptionService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async list(filter: Filter): Promise<Data<IOptionData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { options(filter: $filter) { count rows { id questionid question { id title type } title } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.options!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { option (id: $id) { id questionid question { id title type } title } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: IOptionData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: OptionIn!) { newOption(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async update(input: IOptionData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:String!, $input: OptionIn!) { updateOption(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deleteOption (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
