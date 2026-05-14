import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import Filter from '../../models/filter';
import { TitleService } from '../../services/title-service';
import { Loader } from '../../components/loader/loader';
import Criteria from '../../models/criteria';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { COP, LOP } from '../../models/enum';
import { CommonModule } from '@angular/common';
import { IListItem } from '../../models/lov';
import { Lov } from '../../components/lov/lov';
import { Dialog } from "../../components/dialog/dialog";
import Swal from 'sweetalert2';
import { IOrderData } from '../../models/order';
import { OrderService } from '../../services/order-service';
import { Pager } from "../../components/pager/pager";
import { UserService } from '../../services/user-service';

@Component({
  selector: 'enrollment-list',
  imports: [Loader, CommonModule, ReactiveFormsModule, Lov, Dialog, Pager],
  templateUrl: './list.html',
  styleUrl: './list.css',
})
export default class List implements OnInit {
  rowCount = signal<number>(1);
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  list = signal<IOrderData[]>([]);
  user_list = signal<IListItem[]>([]);
  schedule_list = signal<IListItem[]>([]);
  criteria = signal<Criteria[]>([]);
  loader = signal<boolean>(false);
  statusDialog = signal<boolean>(false);
  type = signal<'ORDER'|'PAYMENT' | null>(null);
  
  filterForm: FormGroup = new FormGroup({
    createdby: new FormControl(''),
    context: new FormControl(''),
    from_date: new FormControl(undefined),
    to_date: new FormControl(undefined),
    order_status: new FormControl(''),
    payment_status: new FormControl(''),
  });

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
          let result = await this.service.changeStatus(this.type()!,formData.id, formData.status);
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
          
          this.load({ criteria: this.criteria()});
          this.statusForm.reset();
          this.hide(this.loader);
          this.hide(this.statusDialog);
        },
        type: 'btn btn-primary w-full',
      },
    ]);
  constructor(
    private user: UserService,
    private service: OrderService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Orders';
    this.loader.set(true);
    await this.load({});
    await this.load_user_list();
    this.loader.set(false);
  }

  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    this.list.set(result?.rows ?? []);
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

  async load_user_list(): Promise<void> {
    let result = await this.user.list({});
    let list: IListItem[] = [];
    if (result.rows) {
      result.rows.forEach((row) => {
        list.push({ id: row.id!, value: `${row.first_name} ${row.last_name}`, label: `${row.first_name} ${row.last_name}` });
      });
    }
    this.user_list.set(list);
  }

  async filter() {
    this.offset = 0;
    let formData = this.filterForm.getRawValue();
    let keys = Object.keys(formData);
    let criteria: Criteria[] = [];
    keys.forEach((k) => {
      let row: Criteria = {};
      if (formData[k] != null && formData[k]?.trim().length > 0) {
        row.column = k;
        row.cop = COP.eq;
        row.value = formData[k];
        if (criteria.length > 0) {
          row.lop = LOP.AND;
        }
        criteria.push(row);
      }
    });

    criteria = criteria.map((x) => {
      if (x.column === 'from_date') {
        x.column = 'createdat';
        x.cop = COP.ge;
      } else if (x.column === 'to_date') {
        x.column = 'createdat';
        x.cop = COP.le;
      }
      return x;
    });
    this.show(this.loader);
    this.criteria.set(criteria);
    await this.load({ criteria: criteria, orderBy: [{ column: 'createdat', asc: false }] });
    this.hide(this.loader);
  }

  async userHandler(item: IListItem): Promise<void> {
    this.filterForm.controls['createdby'].setValue(item?.id);
  }

  show(me: WritableSignal<boolean>, type?: 'ORDER' | 'PAYMENT', id?: string) {
    if(id){
      let row = this.list().find(x=>x.id === id);
      this.type.set(type!);
      switch(type!){
        case "ORDER":
          this.statusForm.patchValue({ id: id, status: row?.order_status});
          break;
        case "PAYMENT":
          this.statusForm.patchValue({ id: id, status: row?.payment_status});
          break;
      }
      
    }
    me.set(true);
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }
}
