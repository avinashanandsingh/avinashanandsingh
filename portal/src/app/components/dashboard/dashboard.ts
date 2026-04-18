import { Component, OnInit, signal } from '@angular/core';
import { StorageService } from '../../services/storage-service';
import { jwtDecode } from 'jwt-decode';
import { Admin } from "./admin/admin";
import { Student } from './student/student';

@Component({
  selector: 'app-dashboard',
  imports: [Admin, Student],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css',
})
export class Dashboard implements OnInit {
  user = signal<any>({});
  constructor(private store: StorageService) {}

  ngOnInit(): void {
    let token = this.store.get('xt');
    if (token) {
      let decoded: any = jwtDecode(token);
      // Decode token and set user info
      // For demo, we'll just set a static user
      this.user.set(decoded);
    }
  }
}
