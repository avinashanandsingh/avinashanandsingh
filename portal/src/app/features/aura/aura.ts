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
  mode = signal<'ADD' | 'EDIT' | null>(null);
  file = signal<File | null>(null);
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

  constructor(
    private service: AuraService,
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
    });
    this.timeslots.push(row);
  }

  removeRow(index: number) {
    this.timeslots.removeAt(index);
  }
  async show(me: WritableSignal<boolean>, id?: string) {
    me.set(true);
    if (id) {
      this.mode.set('EDIT');
    } else {
      this.mode.set('ADD');
    }
    switch (this.mode()) {
      case 'ADD':
        me.set(true);
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);
        this.parentForm.patchValue(row!);
        this.dialogTitle.set('Update Module');
        me.set(true);
        break;
      default:
        me.set(true);
        break;
    }
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
    //this.form.reset();
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
