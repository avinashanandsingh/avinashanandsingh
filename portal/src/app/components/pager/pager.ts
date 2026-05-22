import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';

@Component({
  selector: 'pager',
  imports: [CommonModule],
  templateUrl: './pager.html',
  styleUrl: './pager.css',
})
export class Pager implements OnInit {
  @Input() currentPage = 1;
  @Input() totalPages = 1;
  @Input() maxVisiblePages = 5;
  @Input() hideEllipsis = false;
  @Input() showNavigation = true;
  @Input() showInfo = false;

  @Output() pageChange = new EventEmitter<number>();
  @Output() previousClick = new EventEmitter<void>();
  @Output() nextClick = new EventEmitter<void>();

  private pagesToDisplay: number[] = [];
  private currentMaxVisiblePages: number;
  constructor() {
    this.currentMaxVisiblePages = this.maxVisiblePages;
  }
  ngOnInit(): void {
    
  }

  get pages(): number[] {
    if (this.totalPages <= 1) return [1];
    if (this.totalPages <= this.currentMaxVisiblePages)
      return Array.from({ length: this.totalPages }, (_, i) => i + 1);

    const halfMax = Math.floor(this.currentMaxVisiblePages / 2);
    const startPage = Math.max(1, this.currentPage - halfMax);
    let endPage = Math.min(this.totalPages, startPage + this.currentMaxVisiblePages - 1);

    if (startPage === 1 && endPage < this.maxVisiblePages) {
      this.pagesToDisplay = Array.from({ length: this.currentMaxVisiblePages }, (_, i) => i + 1);
    } else if (startPage + this.currentMaxVisiblePages >= this.totalPages) {
      endPage = this.totalPages;
      this.pagesToDisplay = Array.from({ length: this.currentMaxVisiblePages }, (_, i) =>
        Math.max(1, endPage - this.currentMaxVisiblePages + i + 1),
      );
    } else {
      const start = Math.min(1, this.currentPage - halfMax);
      this.pagesToDisplay = Array.from({ length: endPage - start + 1 }, (_, i) => start + i);
    }

    if (!this.pagesToDisplay.includes(1)) {
      this.pagesToDisplay.unshift(1);
    }
    if (!this.pagesToDisplay.includes(this.totalPages)) {
      this.pagesToDisplay.push(this.totalPages);
    }

    return this.pagesToDisplay;
  }

  get isPreviousDisabled(): boolean {
    return this.currentPage <= 1;
  }

  get isNextDisabled(): boolean {
    return this.currentPage >= this.totalPages;
  }

  get hasMultiplePages(): boolean {
    return this.totalPages > 1;
  }

  get pagesInfo(): string {
    return `Page ${this.currentPage} of ${this.totalPages}`;
  }

  previous(): void {
    if (!this.isPreviousDisabled) {
      this.currentPage--;
      this.pageChange.emit(this.currentPage);
    }
  }

  next(): void {
    if (!this.isNextDisabled) {
      this.currentPage++;
      this.pageChange.emit(this.currentPage);
    }
  }

  goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
      this.pageChange.emit(this.currentPage);
    }
  }
}
