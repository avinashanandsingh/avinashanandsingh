import { Component, OnInit, signal } from '@angular/core';
import { StorageService } from '../../services/storage-service';
import { IUser } from '../../models/user';
import { jwtDecode } from 'jwt-decode';
import { UserService } from '../../services/user-service';
import { CommonModule } from '@angular/common';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Loader } from '../../components/loader/loader';
import Swal from 'sweetalert2';
import { TitleService } from '../../services/title-service';

@Component({
  selector: 'app-profile',
  imports: [CommonModule, ReactiveFormsModule, Loader],
  templateUrl: './profile.html',
  styleUrl: './profile.css',
})
export class Profile implements OnInit {
  user = signal<IUser | null>(null);
  loader = signal<boolean>(false);
  file = signal<File | null>(null);
  blobUrl = signal<string | null>(null);
  form: FormGroup = new FormGroup({
    id: new FormControl(''),
    role: new FormControl(''),
    first_name: new FormControl('', [Validators.required]),
    last_name: new FormControl('', [Validators.required]),
    email: new FormControl('', [Validators.required]),
    phone: new FormControl('', [Validators.required, Validators.pattern('^\\+[1-9]\\d{10,14}$')]),
    profession: new FormControl(''),
    income: new FormControl('', [Validators.pattern(/^\d+(\.\d{1,2})?$/)]),
  });
  constructor(
    private store: StorageService,
    private service: UserService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Profile';
    await this.refresh();
  }
  async refresh() {
    const token = this.store.get('xt');
    if (token) {
      this.loader.set(true);
      let decoded: any = jwtDecode(token);
      let result = await this.service.get(decoded?.id);
      this.user.set(result?.data?.user!);
      this.form.patchValue(result?.data?.user!);
      this.loader.set(false);
    }
  }

  select($event: Event) {
    const target = $event.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      const file = target.files[0];
      this.blobUrl.set(URL.createObjectURL(file));
      this.file.set(file);
    }
  }
  async save(): Promise<void> {
    if (this.form.invalid) return;
    let formData = this.form.getRawValue();

    var fd = new FormData();
    let input: any = {
      ...formData,
      file: null,
    };
    delete input.id;
    input.income = Number(input.income);
    let body = {
      query:
        'mutation update ($id: UUID!, $input: UserIn!) { updateUser(id:$id, input: $input) { id } }',
      variables: {
        id: formData.id,
        input: {
          ...input,
        },
      },
    };

    fd.append('operations', JSON.stringify(body));
    fd.append('map', JSON.stringify({ '0': ['variables.input.file'] }));

    if (this.file()) {
      fd.append('0', this.file()!, this.file()!.name);
    } else {
      fd.append('0', '');
    }
    let result: any;
    this.loader.set(true);
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
      let error = result?.errors?.shift();
      let msg = error?.extensions?.originalError?.message;
      Swal.fire({
        title: 'Failed',
        html: msg,
        icon: 'error',
        timer: 3000,
      });
    }
    await this.refresh();
    this.loader.set(false);
  }
}
