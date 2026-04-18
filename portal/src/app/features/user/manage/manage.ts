import { Component, signal } from '@angular/core';
import { IUser } from '../../../models/user';
import { Status, UserRole } from '../../../models/enum';
import EditDialog from '../edit-dialog/edit-dialog';
import StatusDialog from '../status-dialog/status-dialog';
import { ResetDialog } from '../reset-dialog/reset-dialog';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'manage-user',
  imports: [CommonModule, EditDialog, StatusDialog, ResetDialog],
  templateUrl: './manage.html',
  styleUrl: './manage.css',
})
export default class Manage {
  users: IUser[] = [];
  viewMode = signal<'list' | 'card'>('list');
  editDialogOpen = signal<boolean>(false);
  statusDialogOpen = signal<boolean>(false);
  resetDialogOpen = signal<boolean>(false);
  selectedUser: IUser | null = null;

  // --- Signals ---
  isSearchFocused = signal<boolean>(false);
  filterText = signal<string>('');

  // --- Properties ---
  get filteredUsers(): IUser[] {
    return this.users.filter(
      (user) =>
        user.first_name.toLowerCase().includes(this.filterText().toLowerCase()) ||
        user.last_name.toLowerCase().includes(this.filterText().toLowerCase()) ||
        user.email.toLowerCase().includes(this.filterText().toLowerCase()),
    );
  }

  // --- Constructor ---
  constructor() {}

  // --- Lifecycle ---
  ngOnInit(): void {
    // Load initial data
    this.loadUsers();
  }

  ngOnDestroy(): void {
    // Cleanup any event listeners
  }

  // --- Methods ---

  loadUsers(): void {
    this.users = [
      {
        id: '1',
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        phone: '+1 234 567 890',
        role: UserRole.ADMINISTRATOR,
        status: Status.ACTIVE,
        avatar: 'https://i.pravatar.cc/150?u=john',
        createdat: new Date('2023-01-15'),
      },
      {
        id: '2',
        first_name: 'Jane',
        last_name: 'Smith',
        email: 'jane@example.com',
        phone: '+1 234 567 891',
        role: UserRole.STUDENT,
        status: Status.ACTIVE,
        avatar: 'https://i.pravatar.cc/150?u=jane',
        createdat: new Date('2023-02-20'),
      },
      {
        id: '3',
        first_name: 'Bob',
        last_name: 'Johnson',
        email: 'bob@example.com',
        phone: '+1 234 567 892',
        role: UserRole.INSTRUCTOR,
        status: Status.INACTIVE,
        avatar: 'https://i.pravatar.cc/150?u=bob',
        createdat: new Date('2023-03-10'),
      },
    ];
  }

  openAddEditDialog(): void {
    this.selectedUser = null;
    this.editDialogOpen.set(true);
  }

  openEditDialog(user: IUser): void {
    this.selectedUser = user;
    this.editDialogOpen.set(true);
  }

  openStatusDialog(user: IUser): void {
    this.selectedUser = user;
    this.statusDialogOpen.set(true);
  }

  openResetDialog(user: IUser): void {
    this.selectedUser = user;
    this.resetDialogOpen.set(true);
  }

  toggleViewMode(): void {
    let current = this.viewMode();
    this.viewMode.set(current === 'list' ? 'card' : 'list');
  }

  clearSearch(): void {
    this.filterText.set('');
  }
  saveUser($event: IUser) {
    console.log('Saving user:', $event);
  }

  changeStatus(newStatus: IUser['status'], reason: string): void {
    if (!this.selectedUser) return;

    const updatedUser = { ...this.selectedUser, status: newStatus, reason };
    const index = this.users.findIndex((u) => u.id === this.selectedUser!.id);
    if (index !== -1) {
      this.users[index] = updatedUser;
    }

    this.statusDialogOpen.set(false);
    this.selectedUser = null;
  }

  resetPassword(user: IUser): void {
    // Simulate password reset
    console.log(`Reset password for ${user.email}`);
    this.resetDialogOpen.set(false);
    this.selectedUser = null;
  }

  deleteUser(user: IUser): void {
    if (confirm(`Are you sure you want to delete ${user.first_name} ${user.last_name}?`)) {
      this.users = this.users.filter((u) => u.id !== user.id);
    }
  }
}
