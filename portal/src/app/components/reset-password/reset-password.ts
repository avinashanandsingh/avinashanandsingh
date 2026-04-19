import { CommonModule } from '@angular/common';
import { Component, signal } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { OtpComponent } from '../otp/otp.component';
import { Loader } from '../loader/loader';
import { IdentityService } from '../../services/identity-service';
import { Router } from '@angular/router';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-reset-password',
  imports: [CommonModule, ReactiveFormsModule, OtpComponent, Loader],
  templateUrl: './reset-password.html',
  styleUrl: './reset-password.css',
})
export class ResetPassword {
  loaderDialog = signal<boolean>(false);
  newPass = signal<boolean>(false);
  confirmPass = signal<boolean>(false);

  form: FormGroup = new FormGroup({
    otp: new FormControl('', [Validators.required]),
    newPassword: new FormControl('', [Validators.required]),
    confirmPassword: new FormControl('', [Validators.required]),
  });

  constructor(
    private service: IdentityService,
    private router: Router,
  ) {}

  onOtpChange($event: string) {
    console.log($event);
    if ($event) {
      this.form.controls['otp'].setValue($event);
    } else {
      this.form.controls['otp'].setValue('');
    }
  }

  togglePassword(type: 'NEW' | 'CONFIRM') {
    switch (type) {
      case 'NEW':
        this.newPass.set(!this.newPass());
        break;
      case 'CONFIRM':
        this.confirmPass.set(!this.confirmPass());
        break;
    }
  }

  compare() {
    let formData = this.form.getRawValue();
    let newPassword = formData['newPassword'];
    let confirmPassword = formData['confirmPassword'];
    if (newPassword?.trim()?.length > 0 && confirmPassword?.trim()?.length > 0) {
      return !(newPassword === confirmPassword);
    } else {
      return false;
    }
  }
  async save(): Promise<void> {
    if (this.form.invalid) return;
    let formData = this.form.getRawValue();
    let otp = formData?.otp;
    let password = window.btoa(formData?.newPassword);

    this.loaderDialog.set(true);
    let result = await this.service.reset(otp, password);
    if (result?.data?.reset?.succeed) {
      this.router.navigateByUrl('/signin');
    } else {
      Swal.fire({
        title: 'Failed',
        html: result?.data?.reset?.message,
        icon: 'error',
        timer: 3000,
      });
    }
    this.loaderDialog.set(false);
  }
}
