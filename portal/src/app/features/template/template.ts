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

@Component({
  selector: 'app-template',
  imports: [CommonModule, ReactiveFormsModule, Dialog, Loader, SafePipe],
  templateUrl: './template.html',
  styleUrl: './template.css',
})
export class Template implements OnInit {
  list = signal<ITemplateData[]>([]);
  item = signal<ITemplateData | null>(null);
  typelist = signal<{ name: string; value: string }[]>([]);
  categorylist = signal<{ name: string; value: string }[]>([]);

  loaderDialog = signal<boolean>(false);
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
    private sanitizer: DomSanitizer,
  ) {}
  async ngOnInit(): Promise<void> {
    this.show(this.loaderDialog);
    await this.load({});
    this.typelist.set(await this.service.typelist());
    this.categorylist.set(await this.service.categorylist());
    this.hide(this.loaderDialog);
  }
  async load(filter: Filter) {
    let result = await this.service.list(filter);
    if (result) {
      this.list.set(result?.rows!);
    }
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
    this.show(this.loaderDialog);
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
    await this.load({});
    this.hide(this.loaderDialog);
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
        this.show(this.loaderDialog);
        this.typelist.set(await this.service.typelist());
        this.categorylist.set(await this.service.categorylist());
        this.hide(this.loaderDialog);
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
      this.show(this.loaderDialog);
      let result = await this.service.delete(id);
      if (result) {
        Swal.fire('Saved!', '', 'success');
        this.load({})
        this.hide(this.loaderDialog);
      }
    }
  }
}
