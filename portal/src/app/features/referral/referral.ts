import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { ReferralService } from '../../services/referral-service';
import Filter from '../../models/filter';
import { IReferralData } from '../../models/referral';
import { CommonModule } from '@angular/common';
import { Loader } from '../../components/loader/loader';
import { TitleService } from '../../services/title-service';
import { Pager } from '../../components/pager/pager';
import Criteria from '../../models/criteria';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-referral',
  imports: [CommonModule, Loader, Pager],
  templateUrl: './referral.html',
  styleUrl: './referral.css',
})
export class Referral implements OnInit {
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  criteria = signal<Criteria[]>([]);
  list = signal<IReferralData[]>([]);
  loader = signal<boolean>(false);
  constructor(
    private service: ReferralService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Referrals';
    this.show();
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
    this.hide();
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
    this.show();
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
    this.hide();
  }

  async show() {
    this.loader.set(true);
  }
  hide() {
    this.loader.set(false);
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
      this.show();
      let result = await this.service.delete(id);
      if (result?.data?.deleteReferral) {
        Swal.fire({
          title: 'Success',
          html: 'Referral invite has been deleted',
          icon: 'success',
          timer: 3000,
        });
        await this.load({
          criteria: this.criteria(),
          offset: this.offset,
          limit: this.limit,
        });
        this.hide();
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
