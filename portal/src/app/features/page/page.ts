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

@Component({
  selector: 'app-page',
  imports: [CommonModule, ReactiveFormsModule, Dialog, Loader, SafePipe],
  templateUrl: './page.html',
  styleUrl: './page.css',
})
export class Page implements OnInit {
  rowCount = signal<number>(0)
  list = signal<IPageData[]>([]);
  item = signal<IPageData | null>(null);
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
    private titleService:TitleService,
    private sanitizer: DomSanitizer,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title ="Pages"
    this.show(this.loaderDialog);
    await this.load({});
    this.typelist.set(await this.service.typelist());    
    this.hide(this.loaderDialog);
  }
  async load(filter: Filter) {
    let result = await this.service.list(filter);
    if (result) {
      this.rowCount.set(result?.count!);
      this.list.set(result?.rows!);
    }
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
    this.show(this.loaderDialog);
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
    this.hide(this.loaderDialog);
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
        });
        this.dialogTitle.set('New Page');
        break;
      case 'EDIT':
        this.show(this.loaderDialog);
        this.typelist.set(await this.service.typelist());        
        this.hide(this.loaderDialog);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Page');
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
