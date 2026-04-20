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
  loaderDialog = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  mode = signal<'ADD' | 'EDIT'>('ADD');
  dialogTitle = signal<string>('New Schedule');
  minDate = new Date(new Date().setDate(new Date().getDate()) + 1);
  form: FormGroup = new FormGroup({
    id: new FormControl(undefined),
    courseid: new FormControl('', [Validators.required]),
    title: new FormControl('', [Validators.required]),
    start_date: new FormControl(undefined, [Validators.required]),
    end_date: new FormControl(undefined, [Validators.required]),
    start_time: new FormControl(undefined, [Validators.required]),
    end_time: new FormControl(undefined, [Validators.required]),
    deadline: new FormControl(undefined, [Validators.required]),
    capacity: new FormControl(undefined, [Validators.required, Validators.pattern('^[0-9]*$')]),
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
        this.show(this.loaderDialog);
        switch (this.mode()) {
          case 'ADD':
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
            break;
          case 'EDIT':
            result = await this.service.update(body);
            if (result?.data?.updateSchedule) {              
              Swal.fire({
                title: 'Success',
                html: 'Schedule updated successfully',
                icon: 'success',
                timer: 3000,
              });
            }else{
              let error = result?.errors?.shift();
              let msg = error?.extensions?.originalError?.message;
              Swal.fire({
                title: 'Failed',
                html: msg,
                icon: 'error',
                timer: 3000,
              });
            }
            break;
        }
        this.load({});
        this.hide(this.loaderDialog);
        this.hide(this.formDialog);
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
    let result = await this.course.list({});
    if (result) {
      this.course_list.set(result.rows!);
    }
    await this.load({});
  }
  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    if (result) {
      this.rowCount.set(result.count!);
      this.list.set(result.rows!);
    }
  }
  show(me: WritableSignal<boolean>, id?: string) {
    me.set(true);
    if (id) {
      this.mode.set('EDIT');
    } else {
      this.mode.set('ADD');
    }
    switch (this.mode()) {
      case 'ADD':
        me.set(true);
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Schedule');
        me.set(true);
        break;
      default:
        me.set(true);
        break;
    }
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
  dateHandler(type: 'S' | 'E' | 'D', $event: Date | null) {
    console.log(type, $event);
    switch (type) {
      case 'S':
        this.form.controls['start_date'].setValue($event);
        break;
    }
  }

  async delete(id: string): Promise<void> {
    this.show(this.loaderDialog);
    let result = await this.service.delete(id);
    this.hide(this.loaderDialog);
    this.load({});
  }
}
