import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { Header } from './header';
import Filter from '../models/filter';
import { ICategoryData, ICategoryForm } from '../models/category';
import Data from '../models/data';

@Injectable({
  providedIn: 'root',
})
export class CategoryService{
  url: string = import.meta.env.NG_APP_API;
  constructor(
    private header: Header,
    private api: ApiService,
  ) {}
  async list(filter: Filter): Promise<Data<ICategoryData>> {
    let body = {
      query:
        'query list ($filter: Filter!){ categories(filter: $filter){ count rows { id name slug description status createdat } } }',
      variables: {
        filter: {
          ...filter,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.categories!;
  }
  async add(input: Partial<ICategoryForm>): Promise<ICategoryData> {
    if (input.description!.length == 0) {
      delete input.description;
    }
    let body = {
      query: 'mutation add ($input: CategoryIn!) { addCategory(input: $input) { id } }',
      variables: {
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.updateCategory!;
  }

  async update(id: string, input: ICategoryForm): Promise<ICategoryData> {
    let body = {
      query:
        'mutation update ($id:String!, $input: CategoryIn!){ updateCategory(id:$id, input: $input){ id } }',
      variables: {
        id: id,
        input: {
          ...input,
        },
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.updateCategory!;
  }
  async delete(id: string): Promise<string> {
    let body = {
      query: 'mutation delete ($id: String!) { deleteCategory(id: $id) { id } }',
      variables: {
        id: id,
      },
    };
    let header = this.header.api();
    let result = await this.api.post(this.url, header, body);
    return result?.data?.deleteCategory!;
  }
}
