import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import { StorageService } from './storage-service';
import { IOrderData } from '../models/order';
import Data from '../models/data';
import Filter from '../models/filter';

@Injectable({
  providedIn: 'root',
})
export class OrderService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}
  async contextlist(): Promise<{ name: string; value: string }[]> {
    let body = {
      query: 'query list ($name: String!) { enums (name: $name) { name value } }',
      variables: {
        name: 'context',
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.enums!;
  }
  async list(filter: Filter): Promise<Data<IOrderData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { orders(filter: $filter) { count rows { id orderid context contextid price order_status order_status_reason payment_status payment_status_reason createdby creator { first_name last_name } createdat } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.orders!;
  }

  async get(id: String) {
    let body = {
      query:
        'query get($id: UUID!) { order(id: $id) { id orderid context contextid price order_status order_status_reason payment_status payment_status_reason createdby creator { first_name last_name } createdat updatedby updater { first_name last_name } updatedat } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
  async changeStatus(type: 'ORDER' | 'PAYMENT', id: string, status: string) {
    let body;
    switch (type) {
      case 'ORDER':
        body = {
          query:
            'mutation update($id: UUID!, $input: OrderIn!) { updateOrder (id: $id, input: $input) { id } }',
          variables: {
            id: id,
            "input": {
              order_status: status,
            }
          },
        };
        break;
      case 'PAYMENT':
        body = {
          query:
            'mutation update($id: UUID!, $input: OrderIn!) { updateOrder (id: $id, input: $input) { id } }',
          variables: {
            id: id,
            "input": {
              payment_status: status,
            }
          },
        };
        break;
    }
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
