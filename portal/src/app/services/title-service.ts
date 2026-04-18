import { Injectable, signal } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class TitleService {
  private readonly _title = signal<string>('');
  set title(title: string) {
    this._title.set(title);
  }

  get title() {
    return this._title();
  }
}
