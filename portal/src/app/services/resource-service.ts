// resource.service.ts
import { Injectable } from '@angular/core';
import { IResourceData } from '../models/resource';
import { ApiService } from './api-service';
import { Header } from './header';
import { StorageService } from './storage-service';
import Filter from '../models/filter';
import Data from '../models/data';

@Injectable({
  providedIn: 'root',
})
export class ResourceService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async list(filter: Filter): Promise<Data<IResourceData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { resources(filter: $filter) { count rows { id title url status } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.resources!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { resource (id: $id) { id title url status } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: IResourceData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: ResourceIn!) { addResource(input: $input) { id } }',
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

  async update(input: IResourceData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:String!, $input: ResourceIn!) { updateResource(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deleteResource (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
