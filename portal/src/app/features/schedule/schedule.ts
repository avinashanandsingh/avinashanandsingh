import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { TitleService } from '../../services/title-service';
import { ISchdeuleData } from '../../models/schedule';
import { ScheduleService } from '../../services/schedule-service';
import Filter from '../../models/filter';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { Dialog } from '../../components/dialog/dialog';
import { Loader } from '../../components/loader/loader';
import { CourseService } from '../../services/course-service';
import { ICourseData } from '../../models/course-model';
import Swal from 'sweetalert2';
import Criteria from '../../models/criteria';
import { COP, LOP } from '../../models/enum';
import { geDate } from '../../validator/date/date_ge';
import { leDate } from '../../validator/date/date_le';

@Component({
  selector: 'app-schedule',
  imports: [CommonModule, ReactiveFormsModule, Dialog, Loader],
  templateUrl: './schedule.html',
  styleUrl: './schedule.css',
})
export class Schedule implements OnInit {
  rowCount = signal<number>(1);
  list = signal<ISchdeuleData[]>([]);
  course_list = signal<ICourseData[]>([]);
  schedule = signal<ISchdeuleData | null>(null);
  criteria = signal<Criteria[]>([]);
  loader = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  statusDialogOpen = signal<boolean>(false);
  mode = signal<'ADD' | 'EDIT'>('ADD');
  dialogTitle = signal<string>('New Schedule');
  minDate = new Date(new Date().setDate(new Date().getDate()) + 1);
  maxDate = signal<Date>(new Date());
  filterForm: FormGroup = new FormGroup({
    courseid: new FormControl(''),
    from_date: new FormControl(undefined),
    to_date: new FormControl(undefined),
    capacity: new FormControl(undefined),
    status: new FormControl(''),
  });

  form: FormGroup = new FormGroup(
    {
      id: new FormControl(undefined),
      courseid: new FormControl('', [Validators.required]),
      title: new FormControl('', [Validators.required]),
      start_date: new FormControl(undefined, [Validators.required]),
      end_date: new FormControl(undefined, [Validators.required]),
      start_time: new FormControl(undefined, [Validators.required]),
      end_time: new FormControl(undefined, [Validators.required]),
      deadline: new FormControl(undefined, [Validators.required]),
      capacity: new FormControl(undefined, [Validators.required, Validators.pattern('^[0-9]*$')]),
    },
    {
      // Apply cross-field validator at the group level
      validators: [leDate('start_date', 'deadline'), geDate('start_date', 'end_date')],
    },
  );
  statusForm: FormGroup = new FormGroup({
    id: new FormControl(''),
    status: new FormControl('', Validators.required),
  });

  dialogButtons = signal<Array<{ label: string; action: any; type: any; disabled?: boolean }>>([
    {
      label: 'Close',
      action: () => {
        this.form.reset();
        this.hide(this.formDialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        console.log(this.form.invalid);
        if (this.form.invalid) return;
        let formData = this.form.getRawValue();
        formData.capacity = Number(formData.capacity);
        let body: ISchdeuleData = {
          ...formData,
        };
        let result: any;
        this.show(this.loader);
        if (formData.id) {
          result = await this.service.update(body);
          if (result?.data?.updateSchedule) {
            Swal.fire({
              title: 'Success',
              html: 'Schedule updated successfully',
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
        } else {
          result = await this.service.add(body);
          if (result?.data?.addSchedule) {
            Swal.fire({
              title: 'Success',
              html: 'Schedule saved successfully',
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
        this.hide(this.loader);
        this.hide(this.formDialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  statusDialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.hide(this.statusDialogOpen);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        if (this.statusForm.invalid) return;
        this.show(this.loader);
        let formData = this.statusForm.getRawValue();
        let result = await this.service.changeStatus(formData.id, formData.status);
        if (formData.id) {
          if (result?.data?.changeScheduleStatus) {
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
        this.hide(this.statusDialogOpen);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  constructor(
    private titleService: TitleService,
    private service: ScheduleService,
    private course: CourseService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Schedules';
    this.show(this.loader);
    let result = await this.course.list({});
    if (result) {
      this.course_list.set(result.rows!);
    }
    await this.load({ orderBy: [{ column: 'start_date', asc: false }] });
    this.hide(this.loader);
  }
  async filter() {
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
        x.column = 'start_date';
        x.cop = COP.ge;
      } else if (x.column === 'to_date') {
        x.column = 'start_date';
        x.cop = COP.le;
      }
      return x;
    });
    this.show(this.loader);
    this.criteria.set(criteria);
    await this.load({ criteria: criteria, orderBy: [{ column: 'start_date', asc: false }] });
    this.hide(this.loader);
  }
  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    if (result) {
      this.rowCount.set(result.count!);
      this.list.set(result.rows!);
    } else {
      this.list.set([]);
    }
  }
  async statusChange(id: string, status: string): Promise<void> {
    console.log(id, status);
    this.loader.set(true);
    await this.service.changeStatus(id, status);
    await this.load({criteria: this.criteria()});
    this.loader.set(false);
  }
  showStatusDialog(id: string) {
    console.log(id);
    this.statusDialogOpen.set(true);
    let sch = this.list().find((x) => x.id === id);
    this.statusForm.patchValue({ id: sch!.id, status: sch!.status });
    this.schedule.set(sch!);
  }
  show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT', id?: string) {
    if (mode!) {
      this.mode.set(mode);
    }

    switch (mode!) {
      case 'ADD':
        this.form.reset({ courseid: '' });
        this.dialogTitle.set('New Schedule');
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Schedule');
        break;
    }
    me.set(true);
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
    this.form.reset();
  }

  timeHandler(type: 'S' | 'E', $event: string) {
    console.log(type, $event);
    switch (type) {
      case 'S':
        this.form.controls['start_time'].setValue($event);
        break;
      case 'E':
        this.form.controls['end_time'].setValue($event);
        break;
    }
  }
  dateHandler(type: 'S' | 'E' | 'D', $event: any) {
    console.log(type, $event.target.value);
    let mxd = new Date($event.target.value);
    this.maxDate.set(new Date(mxd.setDate(new Date().getDate()) - 1));
    /* switch (type) {
      case 'S':
        this.form.controls['start_date'].setValue($event);
        break;
    } */
  }

  async delete(id: string): Promise<void> {
    this.show(this.loader);
    let result = await this.service.delete(id);
    this.hide(this.loader);
    this.load({});
  }
}
