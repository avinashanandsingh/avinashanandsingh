import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { IUser } from '../../../models/user';
import { Status } from '../../../models/enum';
import {
  FormControl,
  FormGroup,
  Validators,
  ɵInternalFormsSharedModule,
  ReactiveFormsModule,
} from '@angular/forms';

@Component({
  selector: 'user-status-dialog',
  imports: [ɵInternalFormsSharedModule, ReactiveFormsModule],
  templateUrl: './status-dialog.html',
  styleUrl: './status-dialog.css',
})
export default class StatusDialog implements OnInit {
  @Input() user: IUser | null = null;
  @Output() confirm = new EventEmitter<{ newStatus: Status; reason: string }>();
  @Output() cancel = new EventEmitter<void>();
  isOpen = false;
  form: FormGroup = new FormGroup({
    status: new FormControl('', Validators.required),
    reason: new FormControl('', Validators.required),
  });

  ngOnInit(): void {
    this.form.patchValue({ status: this.user?.status, reason: '' });
  }

  close(): void {
    this.cancel.emit();
  }
  confirmChangeStatus(): void {
    console.log(this.form.invalid, this.form.getRawValue());
    if (this.form.invalid) return;
    //this.confirm.emit(this.reason);
  }
}
