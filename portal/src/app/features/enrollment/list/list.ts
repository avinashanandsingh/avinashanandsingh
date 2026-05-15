import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { EnrollmentService } from '../../../services/enrollment-service';
import Filter from '../../../models/filter';
import { IEnrollmentData } from '../../../models/enrollment';
import { TitleService } from '../../../services/title-service';
import { Loader } from '../../../components/loader/loader';
import Criteria from '../../../models/criteria';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { COP, LOP } from '../../../models/enum';
import { ISchdeuleData } from '../../../models/schedule';
import { ICourseData } from '../../../models/course';
import { CommonModule } from '@angular/common';
import { CourseService } from '../../../services/course-service';
import { IListItem } from '../../../models/lov';
import { Lov } from '../../../components/lov/lov';
import { ScheduleService } from '../../../services/schedule-service';
import { Dialog } from "../../../components/dialog/dialog";
import Swal from 'sweetalert2';

@Component({
  selector: 'enrollment-list',
  imports: [Loader, CommonModule, ReactiveFormsModule, Lov, Dialog],
  templateUrl: './list.html',
  styleUrl: './list.css',
})
export default class List implements OnInit {
  list = signal<IEnrollmentData[]>([]);
  course_list = signal<IListItem[]>([]);
  schedule_list = signal<IListItem[]>([]);
  criteria = signal<Criteria[]>([]);
  loader = signal<boolean>(false);
 
  filterForm: FormGroup = new FormGroup({
    courseid: new FormControl(''),
    scheduleid: new FormControl(''),
    from_date: new FormControl(undefined),
    to_date: new FormControl(undefined),
    status: new FormControl(''),
  });
  statusDialog = signal<boolean>(false);
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
          let result = await this.service.changeStatus(formData.id, formData.status);
          if (formData.id) {
            if (result?.data?.changeEnrollmentStatus) {
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
    private course: CourseService,
    private schedule: ScheduleService,
    private service: EnrollmentService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Enrollments';
    this.loader.set(true);
    await this.load({});
    await this.load_course_list();
    this.loader.set(false);
  }

  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    this.list.set(result?.rows ?? []);
  }

  async load_course_list(): Promise<void> {
    let result = await this.course.list({});
    let list: IListItem[] = [];
    if (result?.rows!) {
      result.rows.forEach((row) => {
        list.push({ id: row.id!, value: row.title, label: row.title });
      });
    }
    this.course_list.set(list);
  }

  async load_schedule_list(courseId: string | number): Promise<void> {
    console.log(courseId);
    let result = await this.schedule.list({
      criteria: [{ column: 'courseid', cop: COP.eq, value: courseId }],
      orderBy: [{ column: 'createdat', asc: false }]
    });
    let list: IListItem[] = [];
    if (result?.rows!) {
      result.rows.forEach((row) => {
        list.push({ id: row.id!, value: `${row.title} - ${row.status}`, label: `${row.title} - ${row.status}`  });
      });
    }
    this.schedule_list.set(list);
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
        x.column = 'enrolledat';
        x.cop = COP.ge;
      } else if (x.column === 'to_date') {
        x.column = 'enrolledat';
        x.cop = COP.le;
      }
      return x;
    });
    this.show(this.loader);
    this.criteria.set(criteria);
    await this.load({ criteria: criteria, orderBy: [{ column: 'enrolledat', asc: false }] });
    this.hide(this.loader);
  }

  async courseHandler(item: IListItem): Promise<void> {
    console.log(item);
    this.filterForm.controls['courseid'].setValue(item?.id);
    if (item) {
      this.loader.set(true);
      await this.load_schedule_list(item?.id);
      this.loader.set(false);
    }
  }
  scheduleHandler(item: IListItem) {
    this.filterForm.controls['scheduleid'].setValue(item?.id);
  }

  show(me: WritableSignal<boolean>, id?: string) {
    if(id){
      let row = this.list().find(x=>x.id === id);
      this.statusForm.patchValue({ id: id, status: row?.status});
    }
    me.set(true);
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }
}
