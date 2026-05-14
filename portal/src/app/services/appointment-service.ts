import { Injectable } from '@angular/core';
import { IAppointmentData } from '../models/appointment';
import Data from '../models/data';
import Filter from '../models/filter';
import { ApiService } from './api-service';
import { Header } from './header';

@Injectable({
  providedIn: 'root',
})
export class AppointmentService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async list(filter: Filter): Promise<Data<IAppointmentData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { appointments(filter: $filter) { count rows { id orderid machine slot start_time end_time creator { first_name last_name } createdat status } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.appointments!;
  }

  async get(filter: Filter) {
    let body = {
      query:
        'query get($filter: Filter!) { appointment(filter: $filter) { id orderid machine slot start_time end_time creator { first_name last_name } createdat status } }',
      variables: {
        filter: filter
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
