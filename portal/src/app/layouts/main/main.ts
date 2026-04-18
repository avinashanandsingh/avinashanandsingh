import { Component, effect, OnDestroy, OnInit, signal } from '@angular/core';
import { Sidebar } from '../../components/layout/sidebar/sidebar';
import { RouterOutlet } from '@angular/router';
import { Header } from '../../components/layout/header/header';
import { TitleService } from '../../services/title-service';

@Component({
  selector: 'app-main-layout',
  imports: [Sidebar, RouterOutlet, Header],
  templateUrl: './main.html',
  styleUrl: './main.css',
})
export class MainLayout implements OnInit, OnDestroy {
  isMobile: boolean = false;
  isSidebarOpen = true;
  year:number = 0;
  pageTitle = signal<string>('');
  private resizeObserver: ResizeObserver | null = null;
  constructor(private titleService: TitleService) {
    this.initializeResizeObserver();
     effect(() => {      
      this.pageTitle.set(this.titleService.title);
    });
  }

  async ngOnInit(): Promise<void> {
    this.year = (new Date()).getFullYear();
    this.checkResize(); // Initial check
  }
  ngOnDestroy(): void {
    this.resizeObserver?.disconnect();
  }

  private initializeResizeObserver(): void {
    if ('ResizeObserver' in window) {
      this.resizeObserver = new ResizeObserver(() => {
        this.checkResize();
      });
      this.resizeObserver.observe(document.body);
    }
  }
  private checkResize(): void {
    this.isMobile = window.innerWidth < 768;

    // Reset sidebar state based on screen size
    // On mobile, sidebar is closed. On desktop, it stays as is (or defaults open)
    if (this.isMobile) {
      this.isSidebarOpen = true;
    } else {
      // On desktop, you might want to keep it open.
      // If you want it to close on resize from desktop->mobile, use:
      // this.isSidebarOpen = true;
    }
  }

  toggleSidebar() {    
    this.isSidebarOpen = !this.isSidebarOpen;
    console.log(this.isSidebarOpen);
  }
}
