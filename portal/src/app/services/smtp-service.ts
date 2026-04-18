import { Injectable } from '@angular/core';
import { ISmtpSetting } from '../models/smtp';
import { ApiService } from './api-service';
import { Header } from './header';

@Injectable({
  providedIn: 'root',
})
export class SmtpService {
  private readonly url = import.meta.env.NG_APP_API;

  constructor(
    private api: ApiService,
    private header: Header,
  ) {}

  /**
   * Saves the configuration with a confirmation step
   */
  async save(input: ISmtpSetting): Promise<any> {
    let body = {
      query:
        'mutation updateSmtp ($id:String!, $input: SmtpIn!) { updateSmtp(id: $id, input: $input) { id } }',
      variables: {
        id: input.id,
        input: {
          host: input.host,
          port: input.port,
          username: input.username,
          password: input.password,
          sender_name: input.sender_name,
          sender_email: input.sender_email,
        },
      },
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }

  async get() {
    let body = {
      query: 'query get { smtp { id host port username password sender_name sender_email } }',
    };
    let header = this.header.api();
    return await this.api.post(this.url, header, body);
  }
}
