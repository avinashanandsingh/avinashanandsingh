import { Component, OnInit, signal } from '@angular/core';
import { form, required, submit, FormField } from '@angular/forms/signals';
import { Router, RouterLink } from '@angular/router';
import { IdentityService } from '../../services/identity-service';
import { StorageService } from '../../services/storage-service';
import { CommonModule } from '@angular/common';
import { Loader } from '../loader/loader';
import Swal from 'sweetalert2';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';

interface SignInModel {
  username: string;
  password: string;
}

@Component({
  selector: 'app-sign-in',
  imports: [CommonModule, ReactiveFormsModule, RouterLink, Loader],
  templateUrl: './sign-in.html',
  styleUrl: './sign-in.css',
})
export class SignIn implements OnInit {
  isLoading = signal<boolean>(false);
  showError = signal<boolean>(false);
  showPassword = signal<boolean>(false);
  model = signal<SignInModel>({
    username: '',
    password: '',
  });
  form: FormGroup = new FormGroup({
    username: new FormControl('', [Validators.required]),
    password: new FormControl('', [Validators.required]),
  });

  constructor(
    private router: Router,
    private identity: IdentityService,
    private store: StorageService,
  ) {}

  async ngOnInit(): Promise<void> {
    let authenticated = await this.identity.isAuthenticated();
    if (authenticated) {
      this.router.navigateByUrl('/admin');
    }
  }

  async submit(event: Event) {
    event.preventDefault();
    if (this.form.invalid) return;
    this.isLoading.set(true);
    let entity = this.form.getRawValue();
    let exist: boolean = await this.identity.exist(entity.username);
    if (exist) {
      let password = window.btoa(entity.password);
      let result = await this.identity.check(entity.username, password);
      if (result?.data?.signin) {
        this.store.set('xt', result?.data?.signin);
        this.router.navigateByUrl('/dashboard');
      } else {
        let error = result?.errors.shift();
        let message = error?.extensions?.originalError?.message;

        Swal.fire({
          title: 'Failed',
          html: message,
          icon: 'error',
          timer: 3000,
        });
      }
    }
    this.isLoading.set(false);
  }
}
