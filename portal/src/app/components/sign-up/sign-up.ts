import { Component, effect, signal } from '@angular/core';
import { form, FormField, pattern, required, submit, validate } from '@angular/forms/signals';
import { Router } from '@angular/router';
import { IdentityService } from '../../services/identity-service';
import { StorageService } from '../../services/storage-service';

interface ISignUp {
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  password: string;
  confirmPassword: string;
}

@Component({
  selector: 'app-sign-up',
  imports: [FormField],
  templateUrl: './sign-up.html',
  styleUrl: './sign-up.css',
})
export class SignUp {
  // --- Signal State Management ---

  model = signal<ISignUp>({
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
  });

  me: any = form(this.model, (schema) => {
    required(schema.first_name);
    required(schema.last_name);
    required(schema.email);
    required(schema.password);
    required(schema.confirmPassword);
    validate(schema.confirmPassword, ({ value, valueOf }) => {
      const password = valueOf(schema.password); // Access another field's value
      if (value() !== password) {
        return { kind: 'mismatch', message: 'Passwords do not match' };
      }
      return null;
    });
  });

  // UI States
  isLoading = signal<boolean>(false);
  showError = signal<boolean>(false);
  successMessage = signal<boolean>(false);

  // Validation Logic
  isPasswordValid = signal<boolean>(false);
  isEmailValid = signal<boolean>(false);
  showPassword = signal<boolean>(false);
  showConfirmPassword = signal<boolean>(false);
  constructor(
    private router: Router,
    private identity: IdentityService,
  ) {
    // Update password validation signals whenever values change
    effect(() => {
      const currentPass = this.model().password;
      const currentConfirm = this.model().confirmPassword;

      const isMatch = currentPass === currentConfirm;
      const hasPassLength = currentPass.length >= 8;

      this.isPasswordValid.set(isMatch && hasPassLength);
    });

    effect(() => {
      const currentEmail = this.model().email;
      const isValid = currentEmail.includes('@') && currentEmail.length > 5;
      this.isEmailValid.set(isValid);
    });
  }

  async onSubmit(event: Event) {
    event.preventDefault();

    await submit(this.me, async () => {
      let entity = this.model();
      let exist: boolean = await this.identity.exist(entity.email);
      if (exist) {
        entity.password = window.btoa(entity.password);
        let result = await this.identity.signup(entity);
        if (result?.data?.signup) {
          this.router.navigateByUrl('/verify');
        }
      }
      // We can return server errors
      /* if (response.error) {
      return [{
        field: myForm.email,
        error: customError({ kind: 'server', message: response.error })
      }];
    } */

      return undefined; // success
    });
  }
}
