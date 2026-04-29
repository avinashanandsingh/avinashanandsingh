import { CommonModule } from '@angular/common';
import { Component, OnInit, signal } from '@angular/core';
import { ISettingData } from '../../models/setting';
import { Loader } from '../../components/loader/loader';
import { SettingService } from '../../services/setting-service';
import Swal from 'sweetalert2';
import Filter from '../../models/filter';
import {
  FormControl,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { TitleService } from '../../services/title-service';

@Component({
  selector: 'app-setting',
  imports: [CommonModule, ReactiveFormsModule, Loader, FormsModule],
  templateUrl: './setting.html',
  styleUrl: './setting.css',
})
export class Setting implements OnInit {
  list = signal<ISettingData[]>([]);
  loader = signal<boolean>(true);
  form: FormGroup = new FormGroup({
    name: new FormControl('', [Validators.required]),
    value: new FormControl('', [Validators.required]),
  });
  constructor(
    private service: SettingService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Settings';
    this.loader.set(true);
    await this.load({});
    this.loader.set(false);
  }
  async load(filter: Filter) {
    let result = await this.service.list(filter);
    this.list.set(result?.rows!);
  }
  async add() {
    if (this.form.invalid) return;
    this.loader.set(true);
    let formData = this.form.getRawValue();
    let result = await this.service.add({ name: formData.name, value: formData.value });
    if (result) {
      Swal.fire('Saved!', '', 'success');
    }
    this.load({});
    this.loader.set(false);
  }

  async update(id: string, key: string, value: string) {
    console.log(id, value);
    this.loader.set(true);
    let result = await this.service.update({ id: id, name: key, value: value });
    if (result) {
      Swal.fire('Saved!', '', 'success');
    }
    this.load({});
    this.loader.set(false);
  }

  async delete(id: String) {
    let dialog = await Swal.fire({
      title: 'Are you sure, want to delete?',
      showDenyButton: true,
      showCancelButton: false,
      confirmButtonText: 'Confirm',
      denyButtonText: 'Cancel',
      customClass: {
        actions: 'my-actions',
        cancelButton: 'order-1 right-gap',
        confirmButton: 'order-2',
        denyButton: 'order-3',
      },
    });

    if (dialog.isConfirmed) {
      this.loader.set(true);
      let result = await this.service.delete(id);
      if (result) {
        Swal.fire('Saved!', '', 'success');
      }
      this.load({});
      this.loader.set(false);
    }
  }
}
