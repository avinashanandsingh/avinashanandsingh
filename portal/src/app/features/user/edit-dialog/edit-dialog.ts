import { Component, EventEmitter, input, Input, Output } from '@angular/core';
import { IUser, IUserFormData } from '../../../models/user';
import { UserRole } from '../../../models/enum';
//import { FormField } from "@angular/forms/signals";

@Component({
  selector: 'user-edit-dialog',
  imports: [],
  templateUrl: './edit-dialog.html',
  styleUrl: './edit-dialog.css',
})
export default class EditDialog {
  @Input() user: IUser | null = null;
  @Input() isEditing: boolean = false;
  @Input() showPreview: boolean = false;
  @Output() save = new EventEmitter<IUser>();
  @Output() cancel = new EventEmitter<void>();
  @Output() close = new EventEmitter<void>();
  isOpen = false;
  formData: IUserFormData = {
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    role: UserRole.ANONYMOUS,
  };

  ngOnInit(): void {
    if (this.user) {
      this.formData = {
        first_name: this.user.first_name,
        last_name: this.user.last_name,
        email: this.user.email,
        phone: this.user.phone,
        role: this.user.role,
      };
    }
  }

  closeDialog(): void {
    this.isOpen = false;
    this.close.emit();
  }
  async submit(): Promise<void> {
    /* this.save.emit({
      ...this.user,
      ...this.formData,
      avatar: this.user?.avatar || 'https://i.pravatar.cc/150?u=0',
    }); */
  }
}
