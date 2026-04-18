import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-sidebar',
  imports: [CommonModule],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css',
})
export class Sidebar {
  /* @Input({ required: false }) isOpen: boolean = true; */
  @Input({ required: false }) activeLink: string = '';
  userName = 'Alex Morgan';
  userRole = 'Admin';    
  constructor(private router: Router) {    
  }

  get currentRoute(): string {
    return this.router.url;
  }
}
