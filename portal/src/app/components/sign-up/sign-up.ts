import { Component, effect, signal } from '@angular/core';
import { form, FormField, pattern, required, submit, validate } from '@angular/forms/signals';
import { Router } from '@angular/router';
import { IdentityService } from '../../services/identity-service';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { equals } from '../../validator/equals';
import Swal from 'sweetalert2';
import { CommonModule } from '@angular/common';
import { Loader } from "../loader/loader";
@Component({
  selector: 'app-sign-up',
  imports: [CommonModule, ReactiveFormsModule, Loader],
  templateUrl: './sign-up.html',
  styleUrl: './sign-up.css',
})
export class SignUp {
  me: FormGroup = new FormGroup(
    {
      first_name: new FormControl('', [Validators.required]),
      last_name: new FormControl('', [Validators.required]),
      email: new FormControl('', [Validators.required, Validators.email]),
      phone: new FormControl('', [Validators.required, Validators.pattern('^\\+[1-9]\\d{10,14}$')]),
      password: new FormControl('', [
        Validators.required,
        Validators.pattern(
          /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!#.%*?&])[A-Za-z\d@$.!#%*?&]{8,}$/,
        ),
      ]),
      confirmPassword: new FormControl('', [
        Validators.required,
        Validators.pattern(
          /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!#.%*?&])[A-Za-z\d@$.!#%*?&]{8,}$/,
        ),
      ]),
    },
    {
      // Apply cross-field validator at the group level
      validators: [equals('newPassword', 'confirmPassword')],
    },
  );

  loader = signal<boolean>(false);

  showPassword = signal<boolean>(false);
  showConfirmPassword = signal<boolean>(false);
  constructor(
    private router: Router,
    private identity: IdentityService,
  ) {}

  async submit() {
    if (this.me.invalid) return;
    let entity = this.me.getRawValue();
    delete entity.confirmPassword;

    let exist: boolean = await this.identity.exist(entity.email);
    if (exist) {
      Swal.fire({
        title: 'Info',
        html: 'Your account is already in our system.',
        icon: 'info',
        timer: 3000,
      });
    } else {
      entity.email = entity.email.toLowerCase();
      entity.password = window.btoa(entity.password);
      let result = await this.identity.signup(entity);
      if (result?.data?.signup) {
        this.router.navigateByUrl('/verify');
      } else {
        let error = result?.errors?.shift();
        let msg = error?.extensions?.originalError?.message;
        Swal.fire({
          title: 'Failed',
          html: msg,
          icon: 'error',
          timer: 3000,
        });
      }
    }
  }
}
