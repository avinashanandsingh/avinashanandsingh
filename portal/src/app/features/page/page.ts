import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { Loader } from '../../components/loader/loader';
import { CommonModule } from '@angular/common';
import { Dialog } from '../../components/dialog/dialog';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import Swal from 'sweetalert2';
import Filter from '../../models/filter';
import { CodeModel } from '@ngstack/code-editor';
import { DomSanitizer } from '@angular/platform-browser';
import { SafePipe } from '../../pipe/safe-pipe';
import { IPageData } from '../../models/page';
import { PageService } from '../../services/page-service';
import { TitleService } from '../../services/title-service';
import { Pager } from '../../components/pager/pager';
import Criteria from '../../models/criteria';

@Component({
  selector: 'app-page',
  imports: [CommonModule, ReactiveFormsModule, Dialog, Loader, SafePipe, Pager],
  templateUrl: './page.html',
  styleUrl: './page.css',
})
export class Page implements OnInit {
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  criteria = signal<Criteria[]>([]);

  list = signal<IPageData[]>([]);
  item = signal<IPageData | null>(null);
  typelist = signal<{ name: string; value: string }[]>([]);
  categorylist = signal<{ name: string; value: string }[]>([]);

  loader = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  dialogTitle = signal<string>('New Template');
  mode = signal<'ADD' | 'EDIT' | 'VIEW'>('ADD');
  activeTab = signal<string>('Body');
  trustedHtml = signal<string>('');
  form: FormGroup = new FormGroup({
    id: new FormControl(undefined),
    type: new FormControl('', [Validators.required]),
    title: new FormControl('', [Validators.required]),
    body: new FormControl('', [Validators.required]),
  });
  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.hide(this.formDialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        await this.save();
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  theme = 'vs';

  model: CodeModel = {
    language: 'html',
    uri: 'index.html',
    value: '<!DOCTYPE html><html><body><h1>Hello World</h1></body></html>',
  };

  options = {
    contextmenu: true,
    minimap: {
      enabled: true,
    },
  };

  constructor(
    private service: PageService,
    private titleService: TitleService,
    private sanitizer: DomSanitizer,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Pages';
    this.show(this.loader);
    await this.load({});
    this.typelist.set(await this.service.typelist());
    this.hide(this.loader);
  }

  async load(filter: Filter) {
    let result = await this.service.list(filter);
    let rows = result?.count ?? 0;
    if (result) {
      this.total.set(Math.ceil(rows / this.limit));
      this.list.set(result?.rows!);
    } else {
      this.list.set([]);
    }
  }

  async pageChange($event: number): Promise<void> {
    this.offset = ($event - 1) * this.limit;
    this.show(this.loader);
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
    this.hide(this.loader);
  }

  onTabClick(id: string) {
    this.activeTab.set(id);
    if (id == 'Preview') {
      const rawHtml = this.form.controls['body'].getRawValue();
      this.trustedHtml.set(rawHtml);
    }
  }
  async save() {
    if (this.form.invalid) return;
    let formData = this.form.getRawValue();
    let input: IPageData = {
      ...formData,
    };

    let result: any;
    this.show(this.loader);
    let id = formData.id;
    if (id) {
      result = await this.service.update(input);
      if (result?.data?.updateTemplate) {
        Swal.fire({
          title: 'Success',
          html: 'Template updated successfully',
          icon: 'success',
          timer: 3000,
        });
      }
    } else {
      console.log('Inside ADD');
      result = await this.service.add(input);
      if (result?.data?.newTemplate) {
        Swal.fire({
          title: 'Success',
          html: 'Template saved successfully',
          icon: 'success',
          timer: 3000,
        });
      }
    }
    await this.load({});
    this.hide(this.loader);
    this.form.reset({
      type: '',
      category: '',
    });
    this.hide(this.formDialog);
  }
  async show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT', id?: string) {
    let row: IPageData | null = null;
    if (id) {
      row = this.list().find((x) => x.id === id)!;
      //this.item.set(row!);
    }
    this.mode.set(mode!);
    switch (mode!) {
      case 'ADD':
        this.form.reset({
          type: '',
          body: '',
        });
        this.trustedHtml.set('');
        this.dialogTitle.set('New Page');
        break;
      case 'EDIT':
        this.show(this.loader);
        this.typelist.set(await this.service.typelist());
        this.hide(this.loader);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Page');
        break;
    }
    me.set(true);
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
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
      if (result?.data?.deletePage) {
        Swal.fire({
          title: 'Success',
          html: 'Page has been deleted',
          icon: 'success',
          timer: 3000,
        });
        await this.load({
          criteria: this.criteria(),
          offset: this.offset,
          limit: this.limit,
        });
        this.hide(this.loader);
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
  }
}
