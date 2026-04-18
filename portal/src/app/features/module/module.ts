import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { ModuleService } from '../../services/module-service';
import Filter from '../../models/filter';
import { IModuleData } from '../../models/module';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ICourseData } from '../../models/course-model';
import { ISchdeuleData } from '../../models/schedule';
import { CommonModule } from '@angular/common';
import { Loader } from '../../components/loader/loader';
import { Dialog } from '../../components/dialog/dialog';
import { CourseService } from '../../services/course-service';
import { ScheduleService } from '../../services/schedule-service';
import { COP } from '../../models/enum';
import { Upload } from '../../components/upload/upload';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-module',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog, Upload],
  templateUrl: './module.html',
  styleUrl: './module.css',
})
export class Module implements OnInit {
  rowCount = signal<number>(0);
  list = signal<IModuleData[]>([]);
  course_list = signal<ICourseData[]>([]);
  schedule_list = signal<ISchdeuleData[]>([]);
  loaderDialog = signal<boolean>(false);
  playerDialog = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  mode = signal<'ADD' | 'EDIT' | null>(null);
  file = signal<File | null>(null);
  dialogTitle = signal<string>('New Module');  
  preview = signal<string>('');
  form: FormGroup = new FormGroup({
    id: new FormControl(undefined),
    courseid: new FormControl('', [Validators.required]),
    scheduleid: new FormControl(''),
    title: new FormControl('', [Validators.required]),
    description: new FormControl(''),
    url: new FormControl(''),
  });
  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
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
        if (this.form.invalid) return;
        let formData = this.form.getRawValue();
        if (formData.url!.length <= 0 && this.file() === null) {
          Swal.fire({
            title: 'Failed',
            html: 'Please upload a video file or enter a URL',
            icon: 'error',
            timer: 3000,
          });
          return;
        }

        var fd = new FormData();
        let input: any = {
          courseid: formData.courseid,
          scheduleid: formData.scheduleid!.length > 0 ? formData.scheduleid : null,
          title: formData.title,
          description: formData.description,
          url: formData.url?.length > 0 ? formData.url : null,
          file: null,
        };
        let body: any = {};
        if (formData.id) {
          console.log('edit: ', formData.id);
          body = {
            query:
              'mutation update ($id: UUID!, $input: ModuleIn!) { updateModule(id:$id, input: $input) { id } }',
            variables: {
              id: formData.id,
              input: {
                ...input,
              },
            },
          };
        } else {
          body = {
            query: 'mutation add ($input: ModuleIn!) { addModule(input: $input) { id } }',
            variables: {
              input: {
                ...input,
              },
            },
          };
        }
        fd.append('operations', JSON.stringify(body));
        fd.append('map', JSON.stringify({ '0': ['variables.input.file'] }));
        if (this.file()) {
          fd.append('0', this.file()!, this.file()!.name);
        } else {
          fd.append('0', '');
        }

        let result: any;
        this.show(this.loaderDialog);
        switch (this.mode()) {
          case 'ADD':
            result = await this.service.saveFormData(fd);
            if (result?.data?.addModule) {
              Swal.fire({
                title: 'Confirmation',
                html: 'Module saved successfully',
                icon: 'success',
                timer: 3000,
              });
            } else {
              Swal.fire({
                title: 'Failed',
                html: 'Unable to add module',
                icon: 'error',
                timer: 3000,
              });
            }
            break;
          case 'EDIT':            
            result = await this.service.saveFormData(fd);
            if (result?.data?.updateModule) {
              Swal.fire({
                title: 'Confirmation',
                html: 'Module updated successfully',
                icon: 'success',
                timer: 3000,
              });
            } else {
              Swal.fire({
                title: 'Failed',
                html: 'Unable to update module',
                icon: 'error',
                timer: 3000,
              });
            }
            break;
        }
        this.hide(this.loaderDialog);
        this.form.reset();
        this.hide(this.formDialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  constructor(
    private service: ModuleService,
    private course: CourseService,
    private schedule: ScheduleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.show(this.loaderDialog);
    await this.load({});
    let result = await this.course.list({});
    if (result) {
      this.course_list.set(result.rows!);
    }
    this.hide(this.loaderDialog);
  }

  async load(filter: Filter) {
    let result = await this.service.list(filter);
    if (result) {
      this.rowCount.set(result.count!);
      this.list.set(result.rows!);
    }
  }
  async load_schedules(filter: Filter) {
    let result = await this.schedule.list(filter);
    if (result) {
      this.form.controls['scheduleid'].setValue('');
      this.schedule_list.set(result.rows!);
    }
  }
  async changeHandler($event: Event): Promise<void> {
    $event.preventDefault();
    let el: any = $event.target as HTMLElement;
    //console.log(el.value);
    this.show(this.loaderDialog);
    await this.load_schedules({
      criteria: [
        {
          column: 'courseid',
          cop: COP.eq,
          value: el.value,
        },
      ],
    });
    this.hide(this.loaderDialog);
  }
  fileChange($event: File | null) {
    this.file.set($event);
  }
  async showPlayer(id:string){
    let row = this.list().find((x) => x.id === id);
    this.preview.set(row?.url!)
    this.playerDialog.set(true);
  }
  async show(me: WritableSignal<boolean>, id?: string) {
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
        this.show(this.loaderDialog);
        await this.load_schedules({
          criteria: [
            {
              column: 'courseid',
              cop: COP.eq,
              value: row!.courseid,
            },
          ],
        });
        this.form.patchValue(row!);
        this.preview.set(row!.url!);
        this.hide(this.loaderDialog);
        this.dialogTitle.set('Update Module');
        me.set(true);
        break;
      default:
        me.set(true);       
        break;
    }
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
    //this.form.reset();
  }
  async delete(id: string): Promise<void> {
    this.show(this.loaderDialog);
    let result = await this.service.delete(id);
    this.load({});
    this.hide(this.loaderDialog);    
  }
}
