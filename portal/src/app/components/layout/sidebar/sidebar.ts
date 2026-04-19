import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { NavigationEnd, Router, RouterLink } from '@angular/router';
import { filter } from 'rxjs';

@Component({
  selector: 'app-sidebar',
  imports: [CommonModule, RouterLink],
  templateUrl: './sidebar.html',
  styleUrl: './sidebar.css',
})
export class Sidebar {
  currentUrl: string = '';
  /* @Input({ required: false }) isOpen: boolean = true; */
  @Input({ required: false }) activeLink: string = '';
  constructor(private router: Router) { 
       this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe((event: NavigationEnd) => {
      this.currentUrl = event.urlAfterRedirects;
    });
  }

  isLinkActive(url: string): boolean {
    return this.currentUrl.includes(url);
  }
}
