import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { AuraService } from '../../services/aura-service';
import Filter from '../../models/filter';
import { IAuraData } from '../../models/aura';
import { CommonModule } from '@angular/common';
import { Loader } from '../../components/loader/loader';
import { Dialog } from '../../components/dialog/dialog';
import {
  FormArray,
  FormBuilder,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import Swal from 'sweetalert2';
import { TitleService } from '../../services/title-service';
import { AppointmentService } from '../../services/appointment-service';
import { COP } from '../../models/enum';
import { IAppointmentData } from '../../models/appointment';
import { OrderService } from '../../services/order-service';

@Component({
  selector: 'app-aura',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog],
  templateUrl: './aura.html',
  styleUrl: './aura.css',
})
export class Aura implements OnInit {
  list = signal<IAuraData[]>([]);
  loader = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  listDialog = signal<boolean>(false);
  slot_list = signal<IAppointmentData[]>([]);
  mode = signal<'ADD' | 'EDIT' | 'BOOKING' | 'STATUS' | 'UPLOAD' | null>(null);
  file = signal<File | null>(null);
  reportFile = signal<File | null>(null);
  dialogTitle = signal<string>('New Service');
  parentForm: FormGroup;

  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.parentForm.reset();
        this.hide(this.formDialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        if (this.parentForm.invalid) return;
        let formData = this.parentForm.getRawValue();
        console.log(formData);
        if (formData.timeslots.length == 0) {
          Swal.fire({
            title: 'Failed',
            html: 'Please add at least one timeslot',
            icon: 'error',
          });
          return;
        }
        formData.timeslots = formData.timeslots.map((row: any) => {
          return {
            name: row?.name!,
            capacity: Number(row.capacity),
            start_time: row?.start_time,
            end_time: row?.end_time,
          };
        });
        let body: IAuraData = {
          ...formData,
        };
        body.price = Number(body.price);
        body.offer = Number(body.offer);
        let result: any;
        this.show(this.loader);
        switch (this.mode()) {
          case 'ADD':
            result = await this.service.add(body);
            break;
          case 'EDIT':
            result = await this.service.update(body);
            break;
          default:
            break;
        }
        if (result) {
          this.load({});
          this.hide(this.formDialog);
        }
        this.hide(this.loader);
      },
      type: 'btn btn-primary w-full',
    },
  ]);

  expandedRowId = signal<string | null>(null);
  statusDialog = signal<boolean>(false);
  statusForm: FormGroup = new FormGroup({
    id: new FormControl(''),
    status: new FormControl('', Validators.required),
  });

  statusDialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.hide(this.statusDialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        if (this.statusForm.invalid) return;
        this.show(this.loader);
        let formData = this.statusForm.getRawValue();
        let result = await this.order.changeStatus('ORDER', formData.id, formData.status);
        if (formData.id) {
          if (result?.data?.updateOrder) {
            Swal.fire({
              title: 'Success',
              html: 'Status changed successfully',
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
        this.statusForm.reset();
        this.hide(this.loader);
        this.hide(this.statusDialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  uploadDialog = signal<boolean>(false);
  slot = signal<IAppointmentData | null>(null);
  uploadDialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.hide(this.uploadDialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        var fd = new FormData();
        let slot = this.slot();
        let body: any = {};
        if (slot !== null) {
          body = {
            query:
              'mutation upload ($id: UUID!, $file: File!) { uploadAuraReport(id:$id, file: $file) { id } }',
            variables: {
              id: slot.id,
              file: null,
            },
          };
        }
        fd.append('operations', JSON.stringify(body));
        fd.append('map', JSON.stringify({ '0': ['variables.file'] }));
        let file = this.reportFile();
        if (file) {
          fd.append('0', file!, file.name);
        } else {
          fd.append('0', '');
        }

        this.show(this.loader);
        let result: any = await this.service.save(fd);
        if (result?.data?.uploadAuraReport) {
          Swal.fire({
            title: 'Success',
            html: 'Report uploaded successfully',
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
        this.hide(this.loader);
        this.hide(this.uploadDialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  constructor(
    private service: AuraService,
    private appointment: AppointmentService,
    private order: OrderService,
    private titleService: TitleService,
    private fb: FormBuilder,
  ) {
    this.parentForm = new FormGroup({
      id: new FormControl(undefined),
      name: new FormControl('', [Validators.required]),
      price: new FormControl('0.00', [Validators.required]),
      offer: new FormControl('0.00', [Validators.required]),
      timeslots: this.fb.array([]),
    });
  }
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Aura Services';
    if (this.timeslots.length == 0) {
      const row = this.fb.group({
        name: ['', Validators.required],
        start_time: ['', [Validators.required]],
        end_time: ['', [Validators.required]],
        capacity: ['', [Validators.required]],
      });
      this.timeslots.push(row);
    }
    this.show(this.loader);
    await this.load({});
    this.hide(this.loader);
  }

  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    if (result) {
      this.list.set(result.rows!);
    }
  }
  get timeslots(): FormArray {
    return this.parentForm.get('timeslots') as FormArray;
  }

  addRow() {
    const row = this.fb.group({
      name: ['', Validators.required],
      start_time: ['', [Validators.required]],
      end_time: ['', [Validators.required]],
      capacity: ['', [Validators.required]],
    });
    this.timeslots.push(row);
  }

  removeRow(index: number) {
    this.timeslots.removeAt(index);
  }
  async show(
    me: WritableSignal<boolean>,
    mode?: 'ADD' | 'EDIT' | 'BOOKING' | 'STATUS' | 'UPLOAD',
    id?: string,
  ) {
    if (mode!) {
      this.mode.set(mode!);
    }
    switch (mode!) {
      case 'ADD':
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);
        this.parentForm.patchValue(row!);
        this.dialogTitle.set('Update Module');
        break;
      case 'BOOKING':
        this.show(this.loader);
        let result = await this.appointment.list({
          criteria: [
            {
              column: 'slotid',
              cop: COP.eq,
              value: id,
            },
          ],
        });
        this.hide(this.loader);
        this.slot_list.set(result?.rows ?? []);
        break;
      case 'STATUS':
        let slot = this.slot_list().find((x) => x.id === id);
        this.statusForm.patchValue({ id: id, status: slot?.status });

        break;
      case 'UPLOAD':
        let slr = this.slot_list().find((x) => x.id === id);
        this.slot.set(slr!);
        break;
    }
    me.set(true);
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
    //this.form.reset();
  }

  selectReportFile(e: any) {
    let file = e?.target?.files[0];
    console.log(file);
    this.reportFile.set(file);
  }
  async delete(id: string): Promise<void> {
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
      this.show(this.loader);
      let result = await this.service.delete(id);
      if (result) {
        Swal.fire({
          title: 'Success',
          html: 'Branding content has been deleted',
          icon: 'success',
          timer: 3000,
        });
        this.load({});
        this.hide(this.loader);
      }
    }
  }

  toggleRow(id: string) {
    this.expandedRowId.update((currentId) => (currentId === id ? null : id));
  }
}
