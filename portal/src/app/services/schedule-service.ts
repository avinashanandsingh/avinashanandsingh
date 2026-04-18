import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { ISchdeuleData } from '../models/schedule';

@Injectable({
  providedIn: 'root',
})
export class ScheduleService {
  url: string = import.meta.env.NG_APP_API;
    constructor(
      private api: ApiService,
      private header: Header,
    ) {}
  
    async list(filter: Filter): Promise<Data<ISchdeuleData>> {
      let body = {
        query:
          'query list ($filter: Filter!) { schedules(filter: $filter) { count rows { id courseid course { id title } title start_date end_date start_time end_time deadline capacity enrollment_count status } } }',
        variables: {
          filter: {
            ...filter,
          },
        },
      };
      let header = this.header.api();
      let result = await this.api.post(this.url, header, body);
      return result?.data?.schedules!;
    }
  
    async get(id: String) {
      let body = {
        query: 'query get($id: UUID!) { schedule (id: $id) { id courseid course { id title } title start_date end_date start_time end_time deadline capacity enrollment_count status } }',
        variables: {
          id: id,
        },
      };
      let header = this.header.api();
      return await this.api.post(this.url, header, body);
    }
  
    async add(input: ISchdeuleData): Promise<any> {
      delete input.id;
      let body = {
        query: 'mutation add ($input: ScheduleIn!) { addSchedule(input: $input) { id } }',
        variables: {
          input: {
            ...input,
          },
        },
      };
      let header = this.header.api();
      return await this.api.post(this.url, header, body);
    }   
  
    async update(input: ISchdeuleData): Promise<any> {
      let id = input.id;
      delete input.id;
      let body = {
        query:
          'mutation update($id:String!, $input: ScheduleIn!) { updateSchedule(id: $id, input: $input) { id } }',
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
        query: 'mutation delete($id: UUID!) { deleteSchedule (id: $id) { id } }',
        variables: {
          id: id,
        },
      };
      let header = this.header.api();
      return await this.api.post(this.url, header, body);
    }
}
