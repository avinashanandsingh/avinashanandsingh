import { Component, effect, OnInit, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ApiService } from './services/api-service';
import { TitleService } from './services/title-service';
import { Meta, Title } from '@angular/platform-browser';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  protected readonly title = signal('Portal');
  constructor(
    private api: ApiService,
    private titleService: TitleService,
    private service: Title,    
  ) {
    effect(() => {      
      this.service.setTitle(this.titleService.title);      
    });
  }
  async ngOnInit(): Promise<void> {    
    await this.api.health();
  }
}
