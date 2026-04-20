import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import { ICourseData } from '../models/course-model';
import { StorageService } from './storage-service';
import Data from '../models/data';

@Injectable({
  providedIn: 'root',
})
export class CourseService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
    private store: StorageService,
  ) {}

  async list(filter: Filter): Promise<Data<ICourseData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { courses(filter: $filter) { count rows { id categoryid category { id name } title description thumbnail url short level free currency price offer status } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.courses!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { course(id: $id) { id categoryid category { id name } title description thumbnail url short level free currency price offer } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: ICourseData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: CourseIn!) { addCourse(input: $input) { id } }',
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

  async update(input: ICourseData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:String!, $input: CourseIn!) { updateCourse(id: $id, input: $input) { id } }',
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

   async publish(id: String) {
    let body = {
      query: 'mutation publish($id: UUID!) { publishCourse(id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
   async archive(id: String) {
    let body = {
      query: 'mutation archive($id: UUID!) { archiveCourse(id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
