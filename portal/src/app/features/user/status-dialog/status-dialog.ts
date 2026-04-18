import { Component, EventEmitter, Input, Output } from '@angular/core';
import { IUser } from '../../../models/user';
import { Status } from '../../../models/enum';

@Component({
  selector: 'user-status-dialog',
  imports: [],
  templateUrl: './status-dialog.html',
  styleUrl: './status-dialog.css',
})
export default class StatusDialog {
  @Input() user: IUser | null = null;
  @Output() confirm = new EventEmitter<{ newStatus: Status; reason: string }>();
  @Output() cancel = new EventEmitter<void>();
  isOpen = false;
  reason = {
    newStatus: Status.ACTIVE,
    reason: ''
  };

  confirmChangeStatus(): void {
    if (this.reason.newStatus && this.reason.reason) {
      this.confirm.emit(this.reason);
    }
  }
}
