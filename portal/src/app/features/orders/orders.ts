import { CommonModule } from '@angular/common';
import { Component, OnInit, signal } from '@angular/core';
import { TitleService } from '../../services/title-service';

@Component({
  selector: 'app-orders',
  imports: [CommonModule],
  templateUrl: './orders.html',
  styleUrl: './orders.css',
})
export class Orders implements OnInit {
  list = signal<any[]>([]);

  constructor(private titleService: TitleService){

  }

  async ngOnInit(): Promise<void> {
    this.titleService.title ="Orders"
  }
}
