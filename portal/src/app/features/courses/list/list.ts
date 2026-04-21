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
import { CategoryService } from '../../../services/category-service';
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
  loader = signal<boolean>(false);
  dialogTitle = signal<string>('New Course');
  mode = signal<'PLAY' | 'ADD' | 'EDIT'>('ADD');

  // --- Modal & Form Signals ---

  formDialog = signal<boolean>(false);
  error = signal<string>('');
  showLevel = signal<boolean>(false);
  showPrice = signal<boolean>(false);
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
            categoryid: formData.categoryid!.length > 0 ? formData.categoryid : null,
            title: formData.title,
            description: formData.description,
            url: formData.url ? formData.url : null,
            short: formData.short,
            level: formData.level,
            free: formData.free,
            price: Number(formData.free ? 0.0 : formData.price),
            offer: Number(formData.free ? 0.0 : formData.offer),
            thumbnail: null,
            video: null,
          };
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
            alert('Successfully saved');
          }
          if (result?.data?.UpdateCourse) {
            alert('Successfully updated');
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
    categoryid: new FormControl(''),
    title: new FormControl('', [Validators.required]),
    description: new FormControl('', [Validators.required]),
    url: new FormControl(''),
    free: new FormControl(false),
    short: new FormControl(false),
    level: new FormControl(''),
    price: new FormControl(undefined, [Validators.pattern('^[0-9]*(\.[0-9]{0,2})?$')]),
    offer: new FormControl(undefined, [Validators.pattern('^[0-9]*(\.[0-9]{0,2})?$')]),
  });

  constructor(
    private service: CourseService,
    private categoryService: CategoryService,
    private titleService: TitleService,
    private router: Router,
    private sanitizer: DomSanitizer,
  ) {}

  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Courses';
    this.show(this.loader);
    let result = await this.categoryService.list({});
    this.category_list.set(result?.rows);
    this.load({});
    this.hide(this.loader)
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
    switch (this.mode()) {
      case 'PLAY':
        row = this.list().find((x) => x.id === id);
        const rawUrl = row?.url!;
        if (rawUrl) {
          const url = this.sanitizer.bypassSecurityTrustResourceUrl(rawUrl!);
          this.safeVideoUrl.set(url);
          this.dialogTitle.set('Watch Video');
        }
        break;
      case 'EDIT':
        row = this.list().find((x) => x.id === id);
        this.form.patchValue(row!);
        console.log(row);
        this.thumbnailUrl.set(row?.thumbnail!);
        this.videoUrl.set(row?.url!);
        this.dialogTitle.set('Update Module');
        break;
    }
    me.set(true);
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }

  edit(id: string) {
    const course = this.list().find((c) => c.id === id);
    if (!course) return;

    this.router.navigate(['/course'], {
      queryParams: { id: id },
    });
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
