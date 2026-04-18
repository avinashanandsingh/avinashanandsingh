import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import { StorageService } from './storage-service';
import { IEnrollmentData } from '../models/enrollment';
import Data from '../models/data';
import Filter from '../models/filter';

@Injectable({
  providedIn: 'root',
})
export class EnrollmentService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async list(filter: Filter): Promise<Data<IEnrollmentData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { enrollments(filter: $filter) { count rows { id userid user { first_name last_name } courseid course { title } scheduleid schedule { title } status enrolledat completedat certificate_issued_at droppedat droppedby { first_name last_name } notes } } }',
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
      query: 'query get($id: UUID!) { resource (id: $id) { id userid user { first_name last_name } courseid course { title } scheduleid schedule { title } status enrolledat completedat certificate_issued_at droppedat droppedby { first_name last_name } notes } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: IEnrollmentData): Promise<any> {
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

  async update(input: IEnrollmentData): Promise<any> {
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

  async drop(id: string, notes: string) {
    let body = {
      query: 'mutation drop($id: UUID!) { drop (id: $id) { id } }',
      variables: {
        id: id,
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
