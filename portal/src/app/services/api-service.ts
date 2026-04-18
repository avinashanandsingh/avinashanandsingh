import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { firstValueFrom } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  url = `${import.meta.env.NG_APP_API}/health`;
  constructor(private http: HttpClient) {}
  async health(): Promise<any> {
    return firstValueFrom(
      this.http.get(this.url, {
        headers: { 'Content-Type': 'application/json' },
      }),
    );
  }

  async post(url: string, headers: any, body: any): Promise<any> {
    return firstValueFrom(
      this.http.post<any>(url, JSON.stringify(body), {
        headers,
      }),
    );
  }
  async postForm(url: string, headers: any, body: any): Promise<any> {
    return firstValueFrom(
      this.http.post<any>(url, body, {
        headers,
      }),
    );
  }
}
