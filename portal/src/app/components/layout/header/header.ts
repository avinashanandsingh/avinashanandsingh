import { Component, DOCUMENT, effect, EventEmitter, Inject, Input, Output, signal } from '@angular/core';
import { HostListener } from '@angular/core';
import { StorageService } from '../../../services/storage-service';
import { jwtDecode } from 'jwt-decode';
import { Router } from '@angular/router';

@Component({
  selector: 'app-header',
  imports: [],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  @Input({ required: false }) isSidebarOpen: boolean = false;
  @Output() toggle = new EventEmitter<void>();
  @Input() pageTitle?: string;
  @Inject(DOCUMENT) private document?: Document;
  isMenuOpen = signal<boolean>(false);
  user = signal<{
    name?: string;    
    email?: string;
    avatar?: string;
    role?: string;
  }>({});

  constructor(private store: StorageService, private router: Router) {
    const token = this.store.get('xt');
    if (token) {
      let decoded: any = jwtDecode(token);
      // Decode token and set user info
      // For demo, we'll just set a static user
      this.user.set({
        name: `${decoded.first_name} ${decoded.last_name}`,
        email: decoded.email,
        avatar: decoded.avatar || 'https://i.pravatar.cc/150?u=jane',
        role: decoded.role,
      });
    }    
  }
  toggleSidebar() {
    this.toggle.emit();
  }

  @HostListener('document:fullscreenchange')
  onFullscreenChange() {
    const isFull = !!this.document?.fullscreenElement;
    console.log('Is Fullscreen:', isFull);
  }

  toggleFullscreen() {
    console.log(this.document?.fullscreenEnabled);
  }
  handleToggleMenu() {
    this.isMenuOpen.update((v) => !v);
  }
  handleLogout() {
    this.isMenuOpen.set(false);
    this.store.clear();
    this.router.navigate(['/signin']);
  }

  handleSettings() {
    this.isMenuOpen.set(false);
    console.log('Open settings modal');
  }
}
