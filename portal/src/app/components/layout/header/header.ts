import {
  Component,
  DOCUMENT,
  effect,
  EventEmitter,
  Inject,
  Input,
  OnInit,
  Output,
  signal,
} from '@angular/core';
import { HostListener } from '@angular/core';
import { StorageService } from '../../../services/storage-service';
import { jwtDecode } from 'jwt-decode';
import { Router } from '@angular/router';
import { Dialog } from '../../dialog/dialog';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { Loader } from '../../loader/loader';
import { equals } from '../../../validator/equals';
import { IdentityService } from '../../../services/identity-service';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-header',
  imports: [CommonModule, ReactiveFormsModule, Dialog, Loader],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header implements OnInit {
  @Input({ required: false }) isSidebarOpen: boolean = false;
  @Output() toggle = new EventEmitter<void>();
  @Input() pageTitle?: string;
  @Inject(DOCUMENT) private document?: Document;
  isMenuOpen = signal<boolean>(false);
  dialog = signal<boolean>(false);
  loader = signal<boolean>(false);
  newPass = signal<boolean>(false);
  confirmPass = signal<boolean>(false);
  user = signal<{
    id?: string;
    name?: string;
    email?: string;
    avatar?: string;
    role?: string;
  }>({});
  form: FormGroup = new FormGroup(
    {
      newPassword: new FormControl('', [
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
  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.dialog.set(false);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {        
        if (this.form.invalid) return;
        this.loader.set(true);
        let data = this.form.getRawValue();        
        let password = window.btoa(data?.newPassword);
        let result = await this.service.change(password);
        if (result?.data?.changePassword?.succeed) {
          Swal.fire({
            title: 'Success',
            html: result?.data?.changePassword?.message,
            icon: 'success',
            timer: 3000,
          });
          this.dialog.set(false);
        } else {
          if (result.errors) {
            let error = result?.errors.shift();
            let message = error?.extensions?.originalError?.message;

            Swal.fire({
              title: 'Failed',
              html: message,
              icon: 'error',
              timer: 3000,
            });
          } else {
            Swal.fire({
              title: 'Failed',
              html: result?.data?.changePassword?.message,
              icon: 'error',
              timer: 3000,
            });
          }
        }
        this.loader.set(false);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  constructor(
    private store: StorageService,
    private service: IdentityService,
    private router: Router,
  ) {}
  ngOnInit(): void {
    const token = this.store.get('xt');
    if (token) {
      let decoded: any = jwtDecode(token);
      // Decode token and set user info
      // For demo, we'll just set a static user
      this.user.set({
        id: decoded.id,
        name: `${decoded.first_name} ${decoded.last_name}`,
        email: decoded.email,
        avatar: decoded.avatar || 'https://i.pravatar.cc/150?u=jane',
        role: decoded.role,
      });
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
  toggleSidebar() {
    this.toggle.emit();
  }

  @HostListener('document:fullscreenchange')
  onFullscreenChange() {
    const isFull = !!this.document?.fullscreenElement;
    console.log('Is Fullscreen:', isFull);
  }

  toggleFullscreen() {
    console.log(this.document?.fullscreenEnabled);
  }
  handleToggleMenu() {
    this.isMenuOpen.update((v) => !v);
  }
  handleLogout() {
    this.isMenuOpen.set(false);
    this.store.clear();
    this.router.navigate(['/signin']);
  }

  handleSettings() {
    this.isMenuOpen.set(false);
    console.log('Open settings modal');
  }
}
