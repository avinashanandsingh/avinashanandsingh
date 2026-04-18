import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IInquiryData } from '../models/inquiry';

@Injectable({
  providedIn: 'root',
})
export class InquiryService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async list(filter: Filter): Promise<Data<IInquiryData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { inquiries(filter: $filter) { count rows { id subject message status creator { first_name last_name } createdat updater { first_name last_name }  } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.inquiries!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { inquiry (id: $id) { id subject message status creator { first_name last_name } createdat updater { first_name last_name } } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }  

  async update(input: IInquiryData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:String!, $input: InquiryIn!) { updateInquiry(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deleteInquiry (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
