import { Component, effect, ElementRef, OnInit, signal, TemplateRef, ViewChild, WritableSignal } from '@angular/core';
import { EnrollmentService } from '../../../services/enrollment-service';
import Filter from '../../../models/filter';
import { IEnrollmentData } from '../../../models/enrollment';
import { TitleService } from '../../../services/title-service';
import { Loader } from '../../../components/loader/loader';
import Criteria from '../../../models/criteria';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { COP, LOP } from '../../../models/enum';
import { CommonModule } from '@angular/common';
import { CourseService } from '../../../services/course-service';
import { IListItem } from '../../../models/lov';
import { Lov } from '../../../components/lov/lov';
import { ScheduleService } from '../../../services/schedule-service';
import { Dialog } from '../../../components/dialog/dialog';
import Swal from 'sweetalert2';
import { Pager } from '../../../components/pager/pager';
import { ExcelService } from '../../../services/excel-service';
import { IUser } from '../../../models/user';

@Component({
  selector: 'enrollment-list',
  imports: [Loader, CommonModule, ReactiveFormsModule, Lov, Dialog, Pager],
  templateUrl: './list.html',
  styleUrl: './list.css',
})
export default class List implements OnInit {
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  criteria = signal<Criteria[]>([]);
  list = signal<IEnrollmentData[]>([]);
  course_list = signal<IListItem[]>([]);
  schedule_list = signal<IListItem[]>([]);
  bulkDialog = signal<boolean>(false);
  loader = signal<boolean>(false);
  user =signal<IUser | null>(null);
  xlrows:any[] =[];
  enrol_list = signal<any[]>([]);
  courseId = signal<string>('');
  scheduleId = signal<string>('');
  popover = signal<boolean>(false);
  

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

        this.load({ criteria: this.criteria() });
        this.statusForm.reset();
        this.hide(this.loader);
        this.hide(this.statusDialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.hide(this.bulkDialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        let courseId = this.courseId();
        let scheduleId = this.scheduleId();
        if(courseId == undefined) return;

        this.show(this.loader);
        let idx = 0;
        let rows = this.xlrows;
        for await (let row of rows) {
          let result = await this.service.import({
            courseid: courseId,
            scheduleid: scheduleId,
            first_name: row.first_name,
            last_name: row.last_name,
            email: row.email,
            phone: row.phone,
            enrolledat: new Date(),
          });
        
          if (result?.data?.import) {
            row.import_status = 'Completed';
            /* Swal.fire({
              title: 'Success',
              html: 'Status changed successfully',
              icon: 'success',
              timer: 3000,
            }); */
          } else {
            row.import_status = 'Failed';
            /* let error = result?.errors?.shift();
            let msg = error?.extensions?.originalError?.message;
            Swal.fire({
              title: 'Failed',
              html: msg,
              icon: 'error',
              timer: 3000,
            }); */
          }

          rows[idx] = row;
          this.enrol_list.set(rows);
          idx++;
        }
        this.load({ criteria: this.criteria() });
        //this.statusForm.reset();
        this.hide(this.loader);
        this.hide(this.bulkDialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
 @ViewChild('file', { static: true }) upload!: ElementRef<any>;
  constructor(
    private course: CourseService,
    private schedule: ScheduleService,
    private service: EnrollmentService,
    private titleService: TitleService,
    private xl: ExcelService,
  ) {
    effect(()=>{
      this.xlrows = this.enrol_list();
      console.log(this.xlrows);
    })
  }
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Enrollments';
    this.loader.set(true);
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
    await this.load_course_list();
    this.loader.set(false);
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
      orderBy: [{ column: 'createdat', asc: false }],
    });
    let list: IListItem[] = [];
    if (result?.rows!) {
      result.rows.forEach((row) => {
        list.push({
          id: row.id!,
          value: `${row.title} - ${row.status}`,
          label: `${row.title} - ${row.status}`,
        });
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

  async importCourseHandler(item: IListItem): Promise<void> {
    if (item) {
      this.loader.set(true);
      this.courseId.set(item.id as string);
      await this.load_schedule_list(item?.id);
      this.loader.set(false);
    }
  }
  
  importScheduleHandler(item: IListItem) {
    this.scheduleId.set(item.id as string);
  }

  show(me: WritableSignal<boolean>, id?: string) {
    if (id) {
      let row = this.list().find((x) => x.id === id);
      this.user.set(row?.user!);
      this.statusForm.patchValue({ id: id, status: row?.status });
    }else{
      this.upload.nativeElement.value="";
      this.enrol_list.set([]);
    }
    me.set(true);
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }


  async selectImportFile(e: any) {
    let file = e?.target?.files[0];
    //var reader = new FileReader();
    //this.fileToUpload = file;
    const arrayBuffer = await file.arrayBuffer();
    let data = await this.xl.read(arrayBuffer);
    console.log("data: ", data);
    //reader.readAsArrayBuffer(file);
    let rows:any[] = [];
    let rownum = 1;
      data.forEach((x: any) => {
        rows.push({
          rowId: rownum,
          first_name: x[1],
          last_name: x[2],
          email: x[3],
          phone: x[4],
          //gender: x[6],
          //dateOfBirth: this.convertDate(x[7]),
          //address: x[20],
          //city: x[21],
          //state: x[22],
          //zip: x[23],
          //worker_desciption: x[24],
          //work_category: x[25],
          import_status: "Loaded",
        });
        rownum++;
      });
      this.enrol_list.set(rows);
    /*reader.onload = async (value: any) => {
      let buffer = value?.target?.result;
      let data = await this.xl.read(buffer);
      //console.log(data);
      
    };*/
  }
}
