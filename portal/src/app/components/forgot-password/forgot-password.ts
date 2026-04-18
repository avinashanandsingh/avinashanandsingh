import { NgClass } from '@angular/common';
import { Component, effect, signal } from '@angular/core';
import { FormField } from "@angular/forms/signals";

@Component({
  selector: 'app-forgot-password',
  imports: [NgClass],
  templateUrl: './forgot-password.html',
  styleUrl: './forgot-password.css',
})
export class ForgotPassword {
  email = signal<string>('');
  isLoading = signal<boolean>(false);
  isSuccess = signal<boolean>(false);
  errorMessage = signal<string>('');
  showBackLink = signal<boolean>(true);
  
  // Validation
  isValidEmail = signal<boolean>(false);

  constructor() {
    // Email Validation Effect
    effect(() => {
      const currentEmail = this.email();
      this.isValidEmail.set(currentEmail.includes('@') && currentEmail.includes('.'));
    });
  }

  onSubmit() {
    if (!this.isValidEmail()) return;
    
    this.isLoading.set(true);
    this.errorMessage.set('');
    this.showBackLink.set(false);

    // Simulate API Call
    setTimeout(() => {
      this.isLoading.set(false);
      this.isSuccess.set(true);
      
      // Reset form
      this.email.set('');
      this.isValidEmail.set(false);
    }, 2000);
  }

  goBackToLogin() {
    window.location.href = '/login'; // Adjust path as needed
  }
}
