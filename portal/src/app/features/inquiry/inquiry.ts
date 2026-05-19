import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { Loader } from '../../components/loader/loader';
import { InquiryService } from '../../services/inquiry-service';
import { CommonModule } from '@angular/common';
import { IInquiryData } from '../../models/inquiry';
import Filter from '../../models/filter';
import { TitleService } from '../../services/title-service';
import Swal from 'sweetalert2';
import Criteria from '../../models/criteria';
import { Pager } from '../../components/pager/pager';

@Component({
  selector: 'app-inquiry',
  imports: [CommonModule, Loader, Pager],
  templateUrl: './inquiry.html',
  styleUrl: './inquiry.css',
})
export class Inquiry implements OnInit {
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  criteria = signal<Criteria[]>([]);
  list = signal<IInquiryData[]>([]);
  loader = signal<boolean>(false);
  constructor(
    private service: InquiryService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Inquiries';
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
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

  async show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT', id?: string) {
    me.set(true);
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
      if (result?.data?.deleteQuestion) {
        Swal.fire({
          title: 'Success',
          html: 'Question has been deleted',
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
