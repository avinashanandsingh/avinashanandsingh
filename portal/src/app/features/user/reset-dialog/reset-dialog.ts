import { Component, EventEmitter, Input, Output } from '@angular/core';
import { IUser } from '../../../models/user';

@Component({
  selector: 'password-reset-dialog',
  imports: [],
  templateUrl: './reset-dialog.html',
  styleUrl: './reset-dialog.css',
})
export class ResetDialog {
  @Input() user: IUser | null = null;
  @Output() reset = new EventEmitter<IUser>();
  @Output() cancel = new EventEmitter<void>();
  isOpen = false;
  notes = '';
  resetPassword(): void {
    this.reset.emit(this.user!);
  }
}
