import { Component, signal, WritableSignal } from '@angular/core';
import { IUser } from '../../../models/user';
import StatusDialog from '../status-dialog/status-dialog';
import { ResetDialog } from '../reset-dialog/reset-dialog';
import { CommonModule } from '@angular/common';
import { Dialog } from '../../../components/dialog/dialog';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { UserService } from '../../../services/user-service';
import { Loader } from '../../../components/loader/loader';
import { Upload } from '../../../components/upload/upload';
import Filter from '../../../models/filter';
import Swal from 'sweetalert2';
import { TitleService } from '../../../services/title-service';
import { Pager } from '../../../components/pager/pager';

@Component({
  selector: 'manage-user',
  imports: [
    CommonModule,
    ReactiveFormsModule,
    StatusDialog,
    ResetDialog,
    Dialog,
    Loader,
    Upload,
    Pager,
  ],
  templateUrl: './manage.html',
  styleUrl: './manage.css',
})
export default class Manage {
  rowCount = signal<number>(1);
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number=0;
  total = signal<number>(0);
  list = signal<IUser[]>([]);
  viewMode = signal<'list' | 'card'>('list');
  mode = signal<'ADD' | 'EDIT'>('ADD');
  editDialogOpen = signal<boolean>(false);
  dialogTitle = signal<string>('New User');
  statusDialogOpen = signal<boolean>(false);
  resetDialogOpen = signal<boolean>(false);
  selectedUser: IUser | null = null;

  // --- Signals ---
  isSearchFocused = signal<boolean>(false);
  filterText = signal<string>('');
  loader = signal<boolean>(false);
  rolelist = signal<{ name: string; value: string }[]>([]);
  avatar = signal<File | null>(null);
  // --- Properties ---
  get filteredUsers(): IUser[] {
    return this.list().filter(
      (user) =>
        user.first_name.toLowerCase().includes(this.filterText().toLowerCase()) ||
        user.last_name.toLowerCase().includes(this.filterText().toLowerCase()) ||
        user.email.toLowerCase().includes(this.filterText().toLowerCase()),
    );
  }

  form: FormGroup = new FormGroup({
    id: new FormControl(undefined),
    role: new FormControl('', [Validators.required]),
    first_name: new FormControl('', [Validators.required]),
    last_name: new FormControl('', [Validators.required]),
    email: new FormControl('', [Validators.required, Validators.email]),
    phone: new FormControl('', [Validators.required, Validators.pattern('^\\+[1-9]\\d{10,14}$')]),
  });

  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.hide(this.editDialogOpen);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        if (this.form.invalid) return;
        let formData = this.form.getRawValue();

        var fd = new FormData();
        let input: any = {
          ...formData,
          file: null,
        };
        delete input.id;
        let body: any = {};
        if (formData.id) {
          console.log('edit: ', formData.id);
          body = {
            query:
              'mutation update ($id: UUID!, $input: UserIn!) { updateUser(id:$id, input: $input) { id } }',
            variables: {
              id: formData.id,
              input: {
                ...input,
              },
            },
          };
        } else {
          body = {
            query: 'mutation add ($input: UserIn!) { addUser(input: $input) { id } }',
            variables: {
              input: {
                ...input,
              },
            },
          };
        }
        fd.append('operations', JSON.stringify(body));
        fd.append('map', JSON.stringify({ '0': ['variables.input.file'] }));

        if (this.avatar()) {
          fd.append('0', this.avatar()!, this.avatar()!.name);
        } else {
          fd.append('0', '');
        }
        let result: any;
        this.show(this.loader);
        if (formData.id) {
          result = await this.service.saveFormData(fd);
          if (result?.data?.updateUser) {
            Swal.fire({
              title: 'Success',
              html: 'User updated successfully',
              icon: 'success',
              timer: 3000,
            });
          }
        } else {
          result = await this.service.saveFormData(fd);
          if (result?.data?.addUser) {
            Swal.fire({
              title: 'Success',
              html: 'User saved successfully',
              icon: 'success',
              timer: 3000,
            });
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
        this.load({});
        this.form.reset({ role: '' });
        this.hide(this.loader);
        this.hide(this.editDialogOpen);
      },
      type: 'btn btn-primary w-full',
    },
  ]);

  // --- Constructor ---
  constructor(
    private service: UserService,
    private titleService: TitleService,
  ) {}

  // --- Lifecycle ---
  async ngOnInit(): Promise<void> {
    // Load initial data
    this.titleService.title = 'Users';
    this.show(this.loader);
    await this.load({
      offset: this.offset,
      limit: this.limit,
    });
    this.rolelist.set(await this.service.rolelist());
    this.hide(this.loader);
  }

  ngOnDestroy(): void {
    // Cleanup any event listeners
  }

  // --- Methods ---

  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    this.total.set(Math.ceil(result?.count! / this.limit));
    this.rowCount.set(result?.count!);    
    this.list.set(result?.rows!);
  }

  async pageChange($event: number):Promise<void> {    
    this.offset = ($event - 1) * this.limit;
    console.log("offset:", this.offset);
    this.show(this.loader);
    await this.load({
      offset: this.offset,
      limit: this.limit,
    });
    this.hide(this.loader);
  }

  fileChange($event: File | null) {
    this.avatar.set($event);
  }

  async show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT', id?: string) {
    let row: IUser | null = null;
    if (id) {
      row = this.list().find((x) => x.id === id)!;
      //this.item.set(row!);
    }
    this.mode.set(mode!);
    switch (mode!) {
      case 'ADD':
        this.form.reset({ role: '' });
        this.dialogTitle.set('New User');
        break;
      case 'EDIT':
        this.show(this.loader);
        this.rolelist.set(await this.service.rolelist());
        this.hide(this.loader);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update User');
        break;
    }
    me.set(true);
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
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
    const index = this.list().findIndex((u) => u.id === this.selectedUser!.id);
    if (index !== -1) {
      this.list()[index] = updatedUser;
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
      this.list.set(this.list().filter((u) => u.id !== user.id));
    }
  }
}
