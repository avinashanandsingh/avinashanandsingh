import { Component, OnInit } from '@angular/core';
import { TitleService } from '../../services/title-service';

@Component({
  selector: 'app-privacy',
  imports: [],
  templateUrl: './privacy.html',
  styleUrl: './privacy.css',
})
export class Privacy implements OnInit {
  constructor(private titleService: TitleService) {}
  ngOnInit(): void {
    this.titleService.title = 'Privacy Policy';
  }
}
