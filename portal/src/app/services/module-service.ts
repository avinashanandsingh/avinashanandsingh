import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import { StorageService } from './storage-service';
import Filter from '../models/filter';
import Data from '../models/data';
import { IModuleData } from '../models/module';

@Injectable({
  providedIn: 'root',
})
export class ModuleService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async list(filter: Filter): Promise<Data<IModuleData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { modules(filter: $filter) { count rows { id title description url courseid course { id title } scheduleid schedule { id title} sort completed completedat status } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.modules;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { module (id: $id) { id title description url courseid course { id title } scheduleid schedule { id title} sort completed completedat } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: IModuleData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: ModuleIn!) { addModule(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
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

  async update(input: IModuleData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:String!, $input: ModuleIn!) { updateModule(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deleteModule (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
