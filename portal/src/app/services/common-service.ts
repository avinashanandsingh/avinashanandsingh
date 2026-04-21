import { inject, Injectable } from '@angular/core';
import { Header } from './header';
import { ApiService } from './api-service';
import { ICountryData, IStateData } from '../models/geo';
import Data from '../models/data';
import Filter from '../models/filter';

@Injectable({
  providedIn: 'root',
})
export class CommonService {
  url: string = import.meta.env.NG_APP_API;
  api = inject(ApiService);
  header = inject(Header);
  constructor() {}

  async country_list(filter: Filter): Promise<Data<ICountryData>> {
    let body = {
      query:
        'query list ($filter: Filter!){ countries(filter: $filter){ count rows { id name } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.countries!;
  }

  async state_list(filter: Filter): Promise<Data<IStateData>> {
    let body = {
      query: 'query list ($filter: Filter!){ states (filter: $filter){ count rows { id name } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.states!;
  }

  async city_list(filter: Filter): Promise<Data<IStateData>> {
    let body = {
      query: 'query list ($filter: Filter!){ cities (filter: $filter){ count rows { id name } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.cities!;
  }
}
