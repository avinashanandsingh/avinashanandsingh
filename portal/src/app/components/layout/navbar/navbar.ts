import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output, signal } from '@angular/core';

@Component({
  selector: 'app-navbar',
  imports: [CommonModule],
  templateUrl: './navbar.html',
  styleUrl: './navbar.css',
})
export class Navbar {
  isMenuOpen = signal<boolean>(false);
  isMobile = signal<boolean>(false);

  user = signal<{
    name: string;
    email: string;
    avatar: string;
    role: string;
  }>({
    name: 'John Doe',
    email: 'john@example.com',
    avatar: 'https://i.pravatar.cc/150?u=john',
    role: 'Admin',
  });

  handleToggleMenu() {
    this.isMenuOpen.update((v) => !v);
  }

  handleCloseMenu() {
    this.isMenuOpen.set(false);
  }

  handleKeyDown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      this.isMenuOpen.set(false);
    }
  }

  ngOnInit() {
    const width = window.innerWidth;
    this.isMobile.set(width < 768);
    window.addEventListener('resize', () => {
      this.isMobile.set(window.innerWidth < 768);
    });
  }

  handleLogout() {
    this.isMenuOpen.set(false);
    // Router.navigate(['/login']);
  }

  handleSettings() {
    this.isMenuOpen.set(false);
    console.log('Open settings modal');
  }

  handleDialog() {
    this.isMenuOpen.set(false);
    console.log('Open settings modal');
  }
}
