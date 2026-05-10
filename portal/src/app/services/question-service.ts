import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import Data from '../models/data';
import { IQuestionData } from '../models/question';

@Injectable({
  providedIn: 'root',
})
export class QuestionService {
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  async typelist(): Promise<{name:string, value: string}[]> {
    let body = {
      query:
        'query list ($name: String!) { enums (name: $name) { name value } }',
      variables: {
        name: "question_type",
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.enums!;
  }
  async list(filter: Filter): Promise<Data<IQuestionData>> {
    let body = {
      query:
        'query list ($filter: Filter!) { questions(filter: $filter) { count rows { id courseid course { id title } type title description status options { id questionid title sort } } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.questions!;
  }

  async get(id: String) {
    let body = {
      query: 'query get($id: UUID!) { service (id: $id) { id courseid course { id title } type title description status options { id questionid title sort } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async add(input: IQuestionData): Promise<any> {
    delete input.id;
    let body = {
      query: 'mutation add ($input: QuestionIn!) { newQuestion(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async update(input: IQuestionData): Promise<any> {
    let id = input.id;
    delete input.id;
    let body = {
      query:
        'mutation update($id:UUID!, $input: QuestionIn!) { updateQuestion(id: $id, input: $input) { id } }',
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
      query: 'mutation delete($id: UUID!) { deleteQuestion (id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
