import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { ICourseData } from '../../../models/course-model';
import { CommonModule, NgClass } from '@angular/common';
import { CourseStatus } from '../../../models/enum';
import { Dialog } from '../../../components/dialog/dialog';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { CourseService } from '../../../services/course-service';
import { Router } from '@angular/router';
import Filter from '../../../models/filter';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { Upload } from '../../../components/upload/upload';
import { Loader } from '../../../components/loader/loader';
import Swal from 'sweetalert2';
import { TitleService } from '../../../services/title-service';

@Component({
  selector: 'app-course',
  imports: [CommonModule, NgClass, Dialog, ReactiveFormsModule, Upload, Loader],
  templateUrl: './list.html',
  styleUrl: './list.css',
})
export default class Course implements OnInit {
  rowCount = signal<number>(0);
  list = signal<ICourseData[]>([]);
  category_list = signal<any>([]);
  levels = signal<{ name: string; value: string }[]>([]);
  loader = signal<boolean>(false);
  dialogTitle = signal<string>('New Course');
  mode = signal<'PLAY' | 'ADD' | 'EDIT'>('ADD');

  // --- Modal & Form Signals ---

  formDialog = signal<boolean>(false);
  error = signal<string>('');
  showLevel = signal<boolean>(false);
  showPrice = signal<boolean>(true);
  playerDialog = signal<boolean>(false);
  thumbnailUrl = signal<string | null>('');
  videoUrl = signal<string>('');
  safeVideoUrl = signal<SafeResourceUrl>('');
  courseStatus = signal<boolean>(true); // true = published

  thumbnail = signal<File | null>(null);
  video = signal<File | null>(null);

  dialogButtons = signal<
    Array<{ label: string; action: any; type: any; validate?: boolean; disabled: boolean }>
  >([
    {
      label: 'Close',
      action: () => {
        this.form.reset();
        this.hide(this.formDialog);
      },
      type: 'btn btn-secondary w-full',
      validate: false,
      disabled: false,
    },
    {
      label: 'Save',
      action: async (): Promise<void> => {
        let formData = this.form.getRawValue();
        if (this.form.valid) {
          this.show(this.loader);
          var fd = new FormData();

          let input: any = {
            title: formData.title,
            description: formData.description,
            duration: formData.duration,
            validity: Number(formData.validity),
            url: formData.url ? formData.url : null,
            certified: formData.certified ?? false,
            short: formData.short ?? false,
            free: formData.free ?? false,
            price: Number(formData.free ? 0.0 : formData.price),
            offer: Number(formData.free ? 0.0 : formData.offer),
            thumbnail: null,
            video: null,
          };
          input['level'] = null;
          if (!formData.short) {
            input['level'] = formData.level;
          }
          let body: any = {};
          if (formData.id) {
            console.log('edit: ', formData.id);
            body = {
              query:
                'mutation update ($id: UUID!, $input: CourseIn!) { updateCourse(id:$id, input: $input) { id } }',
              variables: {
                id: formData.id,
                input: {
                  ...input,
                },
              },
            };
          } else {
            body = {
              query: 'mutation add ($input: CourseIn!) { addCourse(input: $input) { id } }',
              variables: {
                input: {
                  ...input,
                },
              },
            };
          }
          fd.append('operations', JSON.stringify(body));
          fd.append(
            'map',
            JSON.stringify({ '0': ['variables.input.thumbnail'], '1': ['variables.input.video'] }),
          );
          if (this.thumbnail()) {
            fd.append('0', this.thumbnail()!, this.thumbnail()?.name!);
          } else {
            fd.append('0', '');
          }
          if (this.video()) {
            fd.append('1', this.video()!, this.video()?.name!);
          } else {
            fd.append('1', '');
          }

          let result = await this.service.saveFormData(fd);
          if (result?.data?.addCourse) {
            Swal.fire({
              title: 'Success',
              html: 'Course saved successfully',
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
          if (result?.data?.updateCourse) {
            Swal.fire({
              title: 'Success',
              html: 'Course updated successfully',
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

          this.form.reset();
          this.hide(this.formDialog);
          this.load({});
          this.hide(this.loader);
        }
      },
      type: 'btn btn-primary w-full',
      validate: false,
      disabled: false,
    },
  ]);

  form: FormGroup = new FormGroup({
    id: new FormControl(''),
    title: new FormControl('', [Validators.required]),
    description: new FormControl('', [Validators.required]),
    duration: new FormControl('', [Validators.required]),
    validity: new FormControl('', [Validators.required]),
    url: new FormControl(''),
    certified: new FormControl(false),
    free: new FormControl(false),
    short: new FormControl(false),
    level: new FormControl(''),
    price: new FormControl(undefined, [Validators.pattern('^[0-9]*(\.[0-9]{0,2})?$')]),
    offer: new FormControl(undefined, [Validators.pattern('^[0-9]*(\.[0-9]{0,2})?$')]),
  });

  constructor(
    private service: CourseService,
    private titleService: TitleService,
    private router: Router,
    private sanitizer: DomSanitizer,
  ) {}

  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Courses';
    this.loader.set(true);
    //let result = await this.categoryService.list({});
    //this.category_list.set(result?.rows);
    this.levels.set(await this.service.levels());
    await this.load({});
    this.loader.set(false);
  }

  // --- Methods ---
  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    if (result) {
      this.rowCount.set(result.count!);
      this.list.set(result.rows!);
    }
  }
  async archive(id: string): Promise<void> {
    this.show(this.loader);
    let result = await this.service.archive(id);
    if (result?.data?.archiveCourse) {
      Swal.fire({
        title: 'Success',
        html: 'Course archived successfully',
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
    this.load({});
    this.hide(this.loader);
  }

  async publish(id: string): Promise<void> {
    this.show(this.loader);
    let result = await this.service.publish(id);
    if (result?.data?.publishCourse) {
      Swal.fire({
        title: 'Success',
        html: 'Course published successfully',
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
    this.load({});
    this.hide(this.loader);
  }

  changeHandler(type: 'I' | 'V', $event: File | null) {
    switch (type) {
      case 'I':
        this.thumbnail.set($event);
        break;
      case 'V':
        this.video.set($event);
        break;
    }
  }

  async show(me: WritableSignal<boolean>, mode?: 'PLAY' | 'ADD' | 'EDIT', id?: string) {    
    me.set(true);
    if (mode) {
      this.mode.set(mode);
    }
    let row: any;
    switch (mode!) {
      case 'ADD':
        this.form.reset({
          level:''
        });
        this.thumbnailUrl.set(null);
        this.videoUrl.set('');
        this.dialogTitle.set('New Course');
        break;
      case 'PLAY':
        row = this.list().find((x) => x.id === id);
        const rawUrl = row?.url!;
        console.log(rawUrl);
        if (rawUrl) {
          let final = rawUrl;
          if (rawUrl.includes('you')) {
            let id = rawUrl.substring(rawUrl.lastIndexOf('/') + 1, rawUrl.length);
            final = `https://www.youtube.com/embed/${id}`;
          }
          const url = this.sanitizer.bypassSecurityTrustResourceUrl(final);
          this.safeVideoUrl.set(url);
          this.dialogTitle.set('Watch Video');
        }
        break;
      case 'EDIT':
        row = this.list().find((x) => x.id === id);
        this.form.patchValue(row!);
        console.log(row);
        //if(row?.short){
          this.showLevel.set(row?.short);
          this.form.controls['level'].setValue('');
        //}else{
          //this.showLevel.set(true);
        //}
        
        this.showPrice.set(row?.free);
        
        this.thumbnailUrl.set(row?.thumbnail!);
        this.videoUrl.set(row?.url!);
        this.dialogTitle.set('Update Course');
        break;
    }
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }

  togglePublish(id: string) {
    this.list.update((c) =>
      c.map((cur) => {
        if (cur.id === id) {
          return {
            ...cur,
            status:
              cur.status === CourseStatus.ARCHIVED ? CourseStatus.DRAFT : CourseStatus.PUBLISHED,
          };
        }
        return cur;
      }),
    );
  }

  toggleArchive(id: string) {
    this.list.update((c) =>
      c.map((cur) => {
        if (cur.id === id) {
          return {
            ...cur,
            status:
              cur.status === CourseStatus.ARCHIVED ? CourseStatus.PUBLISHED : CourseStatus.ARCHIVED,
          };
        }
        return cur;
      }),
    );
  }

  deleteCourse(id: string) {
    if (confirm('Delete course?')) {
      this.list.update((c) => c.filter((cur) => cur.id !== id));
    }
  }
}
