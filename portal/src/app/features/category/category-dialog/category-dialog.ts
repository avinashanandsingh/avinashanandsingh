import { Component, EventEmitter, Input, input, Output } from '@angular/core';

@Component({
  selector: 'category-dialog',
  imports: [],
  templateUrl: './category-dialog.html',
  styleUrl: './category-dialog.css',
})
export class CategoryDialog {
  @Input() edit: boolean = false;
  @Input() show: boolean = false;
  @Output() close = new EventEmitter<void>();

  openModal() {
      //this.show.emit();
    }
  
    closeModal() {
      this.close.emit();
    }
}
