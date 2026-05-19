import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { Loader } from '../../components/loader/loader';
import { CommonModule } from '@angular/common';
import { ITemplateData } from '../../models/template';
import { Dialog } from '../../components/dialog/dialog';
import { TemplateService } from '../../services/template-service';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import Swal from 'sweetalert2';
import Filter from '../../models/filter';
import { CodeModel } from '@ngstack/code-editor';
import { DomSanitizer } from '@angular/platform-browser';
import { SafePipe } from '../../pipe/safe-pipe';
import { TitleService } from '../../services/title-service';
import { Pager } from '../../components/pager/pager';
import Criteria from '../../models/criteria';

@Component({
  selector: 'app-template',
  imports: [CommonModule, ReactiveFormsModule, Dialog, Loader, SafePipe, Pager],
  templateUrl: './template.html',
  styleUrl: './template.css',
})
export class Template implements OnInit {
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  criteria = signal<Criteria[]>([]);
  list = signal<ITemplateData[]>([]);
  item = signal<ITemplateData | null>(null);
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
    category: new FormControl('', [Validators.required]),
    subject: new FormControl('', [Validators.required]),
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
  /* theme = 'vs-dark';

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
  }; */

  constructor(
    private service: TemplateService,
    private titleService: TitleService,
    private sanitizer: DomSanitizer,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Templates';
    this.show(this.loader);
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
    this.typelist.set(await this.service.typelist());
    this.categorylist.set(await this.service.categorylist());
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
      this.sanitizer.bypassSecurityTrustHtml(rawHtml);
      this.trustedHtml.set(rawHtml);
    }
  }
  async save() {
    if (this.form.invalid) return;
    let formData = this.form.getRawValue();
    let input: ITemplateData = {
      ...formData,
    };

    let result: any;
    this.show(this.loader);
    let id = formData.id;
    if (id) {
      console.log('Inside EDIT');
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
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
    this.hide(this.loader);
    this.form.reset({
      type: '',
      category: '',
    });
    this.hide(this.formDialog);
  }
  async show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT' | 'VIEW', id?: string) {
    let row: ITemplateData | null = null;
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
        this.dialogTitle.set('New Template');
        break;
      case 'EDIT':
        this.show(this.loader);
        this.typelist.set(await this.service.typelist());
        this.categorylist.set(await this.service.categorylist());
        this.hide(this.loader);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Template');
        break;
      case 'VIEW':
        this.dialogTitle.set('View Template');
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
      if (result?.data?.deleteTemplate) {
        Swal.fire({
          title: 'Success',
          html: 'Template has been deleted',
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
