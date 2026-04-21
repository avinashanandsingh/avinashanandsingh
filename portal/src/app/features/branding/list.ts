import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { TitleService } from '../../services/title-service';
import { Loader } from '../../components/loader/loader';
import { Dialog } from '../../components/dialog/dialog';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { IBrandingData } from '../../models/branding';
import Swal from 'sweetalert2';
import { BrandingService } from '../../services/branding-service';
import Filter from '../../models/filter';

@Component({
  selector: 'app-list',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog],
  templateUrl: './list.html',
  styleUrl: './list.css',
})
export default class List implements OnInit {
  list = signal<IBrandingData[]>([]);
  loader = signal<boolean>(false);
  dialog = signal<boolean>(false);
  title = signal<string>('New Branding');
  mode = signal<'ADD' | 'EDIT'>('ADD');
  typelist = signal<{ name: string; value: string }[]>([]);
  file = signal<File | null>(null);
  form: FormGroup = new FormGroup({
    id: new FormControl(''),
    type: new FormControl('', [Validators.required]),
    title: new FormControl('', [Validators.required]),
    content: new FormControl(''),
    url: new FormControl(''),
  });
  actions = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.hide(this.dialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        if (this.form.invalid) return;
        let formData = this.form.getRawValue();

        if (formData?.url?.length <= 0 && this.file() === null) {
          Swal.fire({
            title: 'Failed',
            html: 'Please upload a video file or enter a URL',
            icon: 'error',
            timer: 3000,
          });
          return;
        }

        var fd = new FormData();
        let input: any = {
          type: formData.type,
          title: formData.title,
          content: formData.content,
          url: formData.url!,
          file: null,          
        };
        let body: any = {};
        if (formData.id) {          
          body = {
            query:
              'mutation update ($id: UUID!, $input: BrandingIn!) { updateBranding(id:$id, input: $input) { id } }',
            variables: {
              id: formData.id,
              input: {
                ...input,
              },
            },
          };
        } else {
          body = {
            query: 'mutation add ($input: BrandingIn!) { newBranding(input: $input) { id } }',
            variables: {
              input: {
                ...input,
              },
            },
          };
        }
        fd.append('operations', JSON.stringify(body));
        fd.append(
          'map',
          JSON.stringify({ '0': ['variables.input.file'] }),
        );
        if (this.file()) {
          fd.append('0', this.file()!, this.file()!.name);
        } else {
          fd.append('0', '');
        }        

        let result: any;
        this.show(this.loader);

        result = await this.service.save(fd);
        if (result?.data?.newBranding) {
          Swal.fire({
            title: 'Success',
            html: 'Branding content saved successfully',
            icon: 'success',
            timer: 3000,
          });
        } else if (result?.data?.updateBranding) {
          Swal.fire({
            title: 'Success',
            html: 'Branding content updated successfully',
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

        this.load({});
        this.form.reset();
        this.hide(this.loader);
        this.hide(this.dialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  constructor(
    private titleService: TitleService,
    private service: BrandingService,
  ) {
    this.titleService.title = 'Branding';
  }
  async ngOnInit(): Promise<void> {
    this.show(this.loader);
    await this.load({});
    await this.load_type_list();
    this.hide(this.loader);
  }

  async load_type_list(): Promise<void> {
    let result = await this.service.typelist();
    this.typelist.set(result!);
  }
  async load(filter: Filter) {
    let result = await this.service.list(filter);
    this.list.set(result?.rows! ?? []);
  }

  fileChange($event: Event) {
    console.log($event);
    //this.file.set($event);
  }

  async show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT', id?: string) {
    let row: IBrandingData | null = null;
    if (id) {
      row = this.list().find((x) => x.id === id)!;
      //this.item.set(row!);
    }
    this.mode.set(mode!);
    switch (mode!) {
      case 'ADD':
        console.log('mode.signal: ', this.mode());
        this.form.reset({
          type: '',
          category: '',
        });
        this.title.set('New Branding Content');
        break;
      case 'EDIT':
        this.show(this.loader);
        this.typelist.set(await this.service.typelist());
        this.hide(this.loader);
        this.form.patchValue(row!);
        this.title.set('Update Branding Content');
        break;
    }
    me.set(true);
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }

  async delete(id: string) {
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
}
