import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Otp } from '../otp/otp';
import { IdentityService } from '../../services/identity-service';
import { Loader } from '../loader/loader';
import { Router } from '@angular/router';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-verify',
  imports: [CommonModule, Otp, Loader],
  templateUrl: './verify.html',
  styleUrl: './verify.scss',
})
export default class Verify {
  otp = signal<string>('');
  loader = signal<boolean>(false);
  constructor(
    private identity: IdentityService,
    private router: Router,
  ) {}
  onOtpChange($event: string) {
    this.otp.set($event);
  }
  async verify() {
    let otp = this.otp().trim();
    if (otp.length > 0) {
      this.loader.set(true);
      let result = await this.identity.verify(otp);
      if (result?.data?.verifyEmail?.succeed) {
        this.router.navigateByUrl('/signin');
      } else {
        if (result.errors) {
          let error = result?.errors?.shift();
          let msg = error?.extensions?.originalError?.message;
          Swal.fire({
            title: 'Failed',
            html: msg,
            icon: 'error',
            timer: 3000,
          });
        } else {
          Swal.fire({
            title: 'Failed',
            html: result?.data?.verifyEmail?.message,
            icon: 'error',
            timer: 3000,
          });
        }
      }
      this.loader.set(false);
    }    
  }
}
