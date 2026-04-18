import { Component } from '@angular/core';

@Component({
  selector: 'app-unavailable',
  imports: [],
  templateUrl: './unavailable.html',
  styleUrl: './unavailable.css',
})
export class Unavailable {
  pageTitle = 'Service Unavailable';
  statusColor = 'bg-red-100 text-red-800'; // Tailwind utility for status
  year = (new Date()).getFullYear();
  constructor() {
    // In a real app, you might fetch an error code here.
    console.log("Service interrupted");
  }
}
