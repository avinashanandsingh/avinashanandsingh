import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { ISchdeuleData } from '../models/schedule';
import { IReferralData } from '../models/referral';

@Injectable({
  providedIn: 'root',
})
export class ReferralService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async list(filter: Filter): Promise<Data<IReferralData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { referrals(filter: $filter) { count rows { id referrer referby { id first_name last_name email phone } first_name last_name email referredat acceptedat } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.referrals!;
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

  async refer(input: ISchdeuleData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation refer ($input: ReferralIn!) { refer(input: $input) { id } }',
      variables: {
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
      query: 'mutation delete($id: UUID!) { deleteReferral (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
