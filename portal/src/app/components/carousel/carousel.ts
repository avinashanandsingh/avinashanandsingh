import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output, signal, SimpleChanges } from '@angular/core';

interface CourseItem {
  id: number;
  title: string;
  image: string;
  price: string;
  rating: number;
  students: number;
  instructor: string;
}

@Component({
  selector: 'app-carousel',
  imports: [CommonModule],
  templateUrl: './carousel.html',
  styleUrl: './carousel.css',
})
export class Carousel {
  @Input() items!: CourseItem[];
  courses = signal<CourseItem[]>([]);
  @Input() visibleItems: number = 4; // Items per view (Desktop)
  @Output() onScroll = new EventEmitter<number>();

  // State
  currentIndex = signal<number>(0);
  scrollPosition = signal<number>(0);
  isAnimating = signal<boolean>(false);
  autoplayTimer: any = null;
  isPaused = signal<boolean>(false);
  
  // Responsive Breakpoints (Items to show)
  getVisibleItems(): number {
    const width = window.innerWidth;
    if (width < 768) return 1; // Mobile
    if (width < 1024) return 2; // Tablet
    return this.visibleItems; // Desktop (default 4)
  }

  ngOnInit() {
    this.courses.set(this.items);
    this.startAutoPlay();
    this.setupResizeObserver();
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes['courses']) {
      this.currentIndex.set(0);
      this.startAutoPlay();
    }
  }

  // Auto Play Logic
  startAutoPlay() {
    this.stopAutoPlay();
    this.autoplayTimer = setInterval(() => {
      if (!this.isPaused()) {
        this.next();
      }
    }, 5000); // 5 seconds interval
  }

  stopAutoPlay() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer);
      this.autoplayTimer = null;
    }
  }

  // Slide Functions
  next() {
    if (this.isAnimating()) return;
    const maxIndex = this.courses().length - this.getVisibleItems();
    if (this.currentIndex() >= maxIndex) {
      this.currentIndex.set(0); // Loop back to start
    } else {
      this.currentIndex.set(this.currentIndex() + 1);
    }
    this.isAnimating.set(true);
    this.onScroll.emit(this.currentIndex());
    setTimeout(() => this.isAnimating.set(false), 500);
  }

  prev() {
    if (this.isAnimating()) return;
    if (this.currentIndex() <= 0) {
      this.currentIndex.set(this.courses().length - this.getVisibleItems()); // Loop to end
    } else {
      this.currentIndex.set(this.currentIndex() - 1);
    }
    this.isAnimating.set(true);
    this.onScroll.emit(this.currentIndex());
    setTimeout(() => this.isAnimating.set(false), 500);
  }

  goToSlide(index: number) {
    if (index < 0) index = this.courses().length - this.getVisibleItems();
    if (index >= this.courses().length) index = 0;
    
    this.currentIndex.set(index);
    this.isAnimating.set(true);
    this.onScroll.emit(index);
    setTimeout(() => this.isAnimating.set(false), 500);
  }

  // Pause on Hover
  handleMouseEnter() {
    this.isPaused.set(true);
    this.stopAutoPlay();
  }

  handleMouseLeave() {
    this.isPaused.set(false);
    this.startAutoPlay();
  }

  setupResizeObserver() {
    const resizeObserver = new ResizeObserver(() => {
      this.currentIndex.set(Math.min(this.currentIndex(), this.courses().length - this.getVisibleItems()));
    });
    resizeObserver.observe(document.querySelector('[data-carousel]') as any);
  }
}
