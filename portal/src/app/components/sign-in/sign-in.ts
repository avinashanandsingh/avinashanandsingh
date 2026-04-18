import { Component, OnInit, signal } from '@angular/core';
import { form, required, submit, FormField } from '@angular/forms/signals';
import { Router, RouterLink } from '@angular/router';
import { IdentityService } from '../../services/identity-service';
import { StorageService } from '../../services/storage-service';
import { Dialog } from "../dialog/dialog";
import { CommonModule } from '@angular/common';

interface SignInModel {
  username: string;
  password: string;
}

@Component({
  selector: 'app-sign-in',
  imports: [CommonModule, FormField, RouterLink, Dialog],
  templateUrl: './sign-in.html',
  styleUrl: './sign-in.css',
})
export class SignIn implements OnInit {
  isLoading = signal<boolean>(false);
  showError = signal<boolean>(false);
  showPassword = signal<boolean>(false);
  errorMessage = signal<string>('');
  model = signal<SignInModel>({
    username: '',
    password: '',
  });

  me: any = form(this.model, (schemaPath) => {
    required(schemaPath.username);
    required(schemaPath.password);
  });

  isOpenSignal = signal<boolean>(false);
  // Define buttons dynamically or directly
  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    { label: 'Close', action: () => {
      this.closeDialog();
    }, type: 'btn btn-secondary' },
    //{ label: 'Delete', action: () => console.log('Deleted!'), type: 'btn btn-danger' }
  ]);
  
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

  openDialog() {
    // Use the signal directly
    this.isOpenSignal.set(true);
    // Focus the first focusable element immediately (optional optimization)
    // The component handles focus trap automatically if needed
  }

  closeDialog() {
    this.isOpenSignal.set(false);
  }

  async onSubmit(event: Event) {
    event.preventDefault();
    /*  this.isLoading = true;
    // Perform login logic here
    const credentials = this.model();
    console.log('Logging in with:', credentials);
    // e.g., await this.authService.login(credentials);
    console.log(this.me.valid);
    if(this.me.valid){
      let result = await this.identity.exist(credentials.username);

      this.router.navigateByUrl("/dashboard");
    }
    return false; */

    await submit(this.me, async (f: any) => {
      // 1. At this point all fields are already marked as touched
      // 2. If form is invalid - this function will NOT be called
      // 3. form().submitting() === true during execution
      let entity = this.model();
      let exist: boolean = await this.identity.exist(entity.username);
      if (exist) {
        let password = window.btoa(entity.password);
        let result = await this.identity.check(entity.username, password);
        if (result?.data?.signin) {
          this.store.set('xt', result?.data?.signin);
          this.router.navigateByUrl('/dashboard');
        }else{
          let error = result?.errors.shift();          
          let message = error?.extensions?.originalError?.message;
          console.error('Login failed:', message);
          this.isOpenSignal.set(true);
          this.errorMessage.set(message);
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
