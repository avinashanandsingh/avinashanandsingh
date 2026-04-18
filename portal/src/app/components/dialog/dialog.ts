import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output, signal, SimpleChanges } from '@angular/core';

@Component({
  selector: 'app-dialog',
  imports: [CommonModule],
  templateUrl: './dialog.html',
  styleUrl: './dialog.css',
})
export class Dialog {
  // --- State ---
  @Input() isOpen = signal<boolean>(false);
  @Input() backdrop: boolean = true;
  @Input() footer: boolean = true;
  @Output() close = new EventEmitter<void>();
  isAnimating = signal<boolean>(false);

  // --- Inputs ---
  // Use signals for external state management (Angular 17+)
  @Input() title:string ='';
  body = signal<string>('');
  bodyHtml = signal<boolean>(false); // Whether content is raw HTML
  @Input() buttons = signal<
    Array<{ label: string; action: any; type: 'primary' | 'secondary' | 'danger', validate?: boolean, disabled?: boolean }>
  >([]);
  showCloseIcon = signal<boolean>(true);
  // --- Focus Trap State ---
  focusableElements: any = Array<Element>(); // Store elements inside for refocus

  // --- Inputs ---
  constructor() {}

  ngOnInit(): void {}

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['isOpen']) {
      // Trigger animation or focus trap update
    }
  }

  // --- Actions ---
  closeMe(): void {
    // Trigger animation
    this.isOpen.set(false);
    this.close.emit();
    /* // Restore focus to the first focusable element after a short delay
    setTimeout(() => {
      if (this.focusableElements.length > 0) {
        this.focusableElements[0].focus();
      }
    }, 100); */
  }

  handleBackdropClick($event: MouseEvent): void {
    if (this.backdrop) {
      // Close only if click is on the backdrop (not the modal itself)
      const target = $event.target as HTMLElement;
      if (target.closest('.dialog-overlay')) {
        this.closeMe();
      }
    }
  }

  handleEsc(event: KeyboardEvent): void {
    if (event.key === 'Escape') {
      event.preventDefault();
      this.closeMe();
    }
  }

  handleFocus(event: FocusEvent): void {
    // Optional: Store current focused element to restore later
  }
}
