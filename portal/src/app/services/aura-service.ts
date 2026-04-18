import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IAuraData } from '../models/aura';

@Injectable({
  providedIn: 'root',
})
export class AuraService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async list(filter: Filter): Promise<Data<IAuraData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { services(filter: $filter) { count rows { id name price offer status timeslots { id serviceid name start_time end_time } } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.services!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { service (id: $id) { id name price offer status timeslots { id serviceid name start_time end_time } } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: IAuraData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: ServiceIn!) { addService(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async update(input: IAuraData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:String!, $input: ServiceIn!) { updateService(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deleteService (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
