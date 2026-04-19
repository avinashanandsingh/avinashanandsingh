import { CommonModule, NgClass } from '@angular/common';
import { Component, effect, signal } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { Loader } from '../loader/loader';
import { IdentityService } from '../../services/identity-service';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-forgot-password',
  imports: [CommonModule, ReactiveFormsModule, Loader],
  templateUrl: './forgot-password.html',
  styleUrl: './forgot-password.css',
})
export class ForgotPassword {
  email = signal<string>('');
  loaderDialog = signal<boolean>(false);
  isSuccess = signal<boolean>(false);
  errorMessage = signal<string>('');
  showBackLink = signal<boolean>(true);

  // Validation
  isValidEmail = signal<boolean>(false);
  form: FormGroup = new FormGroup({
    email: new FormControl('', [Validators.required, Validators.email]),
  });
  constructor(
    private router: Router,
    private service: IdentityService,
  ) {}

  async onSubmit(): Promise<void> {
    if (this.form.invalid) return;
    let email = this.form.getRawValue().email;
    this.loaderDialog.set(true);
    let result: any = await this.service.fogot(email);    
    if (result?.data?.forgot?.succeed) {
      this.router.navigateByUrl('/reset');
    } else {
        Swal.fire({
          title: 'Failed',
          html: result?.data?.forgot?.message,
          icon: 'error',
          timer: 3000,
        });
    }
    this.loaderDialog.set(false);
    //this.showBackLink.set(false);
  }

  goBackToLogin() {
    this.router.navigateByUrl('/signin');
  }
}
