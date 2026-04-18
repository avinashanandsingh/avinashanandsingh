import { CommonModule } from '@angular/common';
import { Component, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'admin-dashboard',
  imports: [CommonModule, FormsModule],
  templateUrl: './admin.html',
  styleUrl: './admin.css',
})
export class Admin {
  isSidebarOpen = signal<boolean>(true);
  isLoading = signal<boolean>(false);

  // Data Signals (Simulated Data for Demo)
  totalStudents = signal<number>(1245);
  totalCourses = signal<number>(85);
  totalRevenue = signal<string>('$124,000');
  activeUsers = signal<number>(342);

  // Simulate loading data
  simulateDataLoad() {
    this.isLoading.set(true);
    setTimeout(() => {
      // Randomize numbers slightly for animation effect
      this.totalStudents.set(Math.floor(Math.random() * 1000) + 1000);
      this.totalRevenue.set('$' + (Math.floor(Math.random() * 50000) + 100000));
      this.isLoading.set(false);
    }, 1000);
  }
}
