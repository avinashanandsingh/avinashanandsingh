import { Component, signal, WritableSignal } from '@angular/core';
import { TitleService } from '../../services/title-service';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { MeditationService } from '../../services/meditation-service';
import { IMeditationData } from '../../models/meditation';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Loader } from '../../components/loader/loader';
import Filter from '../../models/filter';
import { CommonModule } from '@angular/common';
import { Dialog } from '../../components/dialog/dialog';
import { Upload } from '../../components/upload/upload';
import Swal from 'sweetalert2';
import { CourseService } from '../../services/course-service';
import { IListItem } from '../../models/lov';
import { Lov } from '../../components/lov/lov';
import { COP } from '../../models/enum';
import { Pager } from '../../components/pager/pager';
import Criteria from '../../models/criteria';

@Component({
  selector: 'app-meditation',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog, Upload, Lov, Pager],
  templateUrl: './meditation.html',
  styleUrl: './meditation.css',
})
export class Meditation {
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  criteria = signal<Criteria[]>([]);
  list = signal<IMeditationData[]>([]);
  course_list = signal<IListItem[]>([]);
  loader = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  courseId = signal<string>('');
  playerDialog = signal<boolean>(false);
  preview = signal<SafeResourceUrl | null>(null);
  mode = signal<'ADD' | 'EDIT'>('ADD');
  dialogTitle = signal<string>('New Meditation Audio');
  dragItem: IMeditationData | null = null;
  dragOverItem: IMeditationData | null = null;
  imageFile = signal<File | null>(null);
  audioFile = signal<File | null>(null);
  thumbnail = signal<string>('');
  audio = signal<string>('https://d1bsxhak5ljzei.cloudfront.net/audios/file_example_MP3_5MG.mp3');
  msg?: string;
  form: FormGroup = new FormGroup({
    id: new FormControl(undefined),
    courseid: new FormControl('', [Validators.required]),
    title: new FormControl('', [Validators.required]),
    url: new FormControl(''),
    free: new FormControl('', Validators.required),
    price: new FormControl(undefined, [Validators.pattern('^[0-9]*(\.[0-9]{0,2})?$')]),
    offer: new FormControl(undefined, [Validators.pattern('^[0-9]*(\.[0-9]{0,2})?$')]),
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
        if ((formData.url ?? '').length <= 0 && this.audioFile === null) {
          this.msg = 'Either upload file or provide url';
        }
        var fd = new FormData();
        let input: any = {
          courseid: formData.courseid,
          title: formData.title,
          url: formData.url,
          audio: null,
          free: formData.free,
          price: formData.price ? Number(formData.price) : 0,
          offer: formData.offer ? Number(formData.offer) : 0,
        };
        let body: any = {};
        if (formData.id) {
          console.log('edit: ', formData.id);
          body = {
            query:
              'mutation update ($id: UUID!, $input: MeditationIn!) { updateMeditation(id:$id, input: $input) { id } }',
            variables: {
              id: formData.id,
              input: {
                ...input,
              },
            },
          };
        } else {
          body = {
            query: 'mutation add ($input: MeditationIn!) { addMeditation(input: $input) { id } }',
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
          JSON.stringify({ '0': ['variables.input.thumbnail'], '1': ['variables.input.audio'] }),
        );
        if (this.imageFile()) {
          fd.append('0', this.imageFile()!, this.imageFile()!.name);
        } else {
          fd.append('0', '');
        }

        if (this.audioFile()) {
          fd.append('1', this.audioFile()!, this.audioFile()!.name);
        } else {
          fd.append('1', '');
        }

        let result: any;
        this.show(this.loader);
        if (formData.id) {
          console.log('id: ', formData.id);
          result = await this.service.save(fd);
          if (result?.data?.updateMeditation) {
            Swal.fire({
              title: 'Success',
              html: 'Meditation audio updated successfully',
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
          result = await this.service.save(fd);
          if (result?.data?.addMeditation) {
            Swal.fire({
              title: 'Success',
              html: 'Meditation audio saved successfully',
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

  constructor(
    private service: MeditationService,
    private course: CourseService,
    private titleService: TitleService,
    private sanitizer: DomSanitizer,
  ) {}
  async ngOnInit(): Promise<void> {
    this.loader.set(true);
    this.titleService.title = 'Meditations';
    this.preview.set(
      this.sanitizer.bypassSecurityTrustResourceUrl('https://samplelib.com/mp3/sample-6s.mp3'),
    );
    await this.load_course_list();
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
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
    let result = await this.course.list({
      criteria: [
        {
          column: 'short',
          cop: COP.eq,
          value: false,
        },
      ],
    });
    let list: IListItem[] = [];
    if (result?.rows!) {
      result.rows.forEach((row) => {
        list.push({
          id: row.id!,
          value: `${row.title} - ${row.level}`,
          label: `${row.title} - ${row.level}`,
        });
      });
    }
    this.course_list.set(list);
  }

  async showPlayer(id: string) {
    let row = this.list().find((x) => x.id === id);
    const url = this.sanitizer.bypassSecurityTrustResourceUrl(row?.url!);
    this.preview.set(url);
    this.playerDialog.set(true);
  }

  async courseHandler(item: IListItem) {
    if (item != null) {
      this.form.controls['courseid'].setValue(item.id!);
    }
  }

  freeChange($event: Event) {
    let value = ($event.target as HTMLInputElement).checked;
    this.form.controls['free'].setValue(value);
    if (value) {
      this.form.controls['price'].disable();
      this.form.controls['offer'].disable();
    } else {
      this.form.controls['price'].enable();
      this.form.controls['offer'].enable();
    }
  }
  show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT', id?: string) {
    if (mode!) {
      this.mode.set(mode);
    }
    switch (this.mode()) {
      case 'ADD':
        this.courseId.set('');
        this.form.reset({ courseid: '' });
        this.preview.set(null);
        this.thumbnail.set('');
        this.audio.set('');
        this.dialogTitle.set('New Meditation Audio');
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);
        this.courseId.set(row?.courseid!);
        if (row?.free) {
          this.form.controls['price'].disable();
          this.form.controls['offer'].disable();
        } else {
          this.form.controls['price'].enable();
          this.form.controls['offer'].enable();
        }
        this.thumbnail.set(row!?.thumbnail!);
        this.audio.set(row?.url!);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Meditation Audio');
        break;
    }
    me.set(true);
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
    this.form.reset();
  }

  fileChange(type: 'I' | 'A', $event: File | null) {
    console.log(type, $event);
    switch (type) {
      case 'I':
        this.imageFile.set($event);
        break;
      case 'A':
        this.audioFile.set($event);
        break;
    }
  }
  async statusChange(id: string, $event: Event): Promise<void> {
    let value = ($event.target as HTMLInputElement).checked;
    let status = value ? 'ACTIVE' : 'INACTIVE';

    let dialog = await Swal.fire({
      title: 'Are you sure, want change the status?',
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
      let result = await this.service.changeStatus(id, status);
      if (result?.data?.changeMeditationStatus) {
        Swal.fire({
          title: 'Success',
          html: 'Status change complete.',
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

      await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
      this.hide(this.loader);
    }
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
      if (result) {
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
      }
    }
  }

  // --- Drag and Drop Logic ---

  onDragStart(event: any, item: IMeditationData) {
    this.dragItem = item;
    event.dataTransfer.effectAllowed = 'move';
  }

  onDragOver(event: any) {
    event.preventDefault(); // Necessary to allow dropping
    if (this.dragItem && this.dragItem !== this.dragOverItem) {
      // Prevent duplicate drop logic
      const rect = (event.target as HTMLElement).getBoundingClientRect();
      const offset = 0;
      const x = event.clientX - rect.left;
      const y = event.clientY - rect.top;
      const above = y < rect.height / 2;

      // Only allow drop if not already over
      if (!this.dragOverItem) {
        this.dragOverItem = this.dragItem;
        const index = this.list().indexOf(this.dragItem);
        if (index > -1) {
          this.list().splice(index, 1);
          this.list().splice(index + (above ? -1 : 0), 0, this.dragItem);
          this.dragOverItem = this.dragItem; // Update current dragOver
        }
      }
    }
  }

  onDragEnter(event: any) {
    event.preventDefault();
    if (this.dragItem) {
      event.target.appendChild(this.dragItem); // Visual placeholder could be here
    }
  }

  onDragLeave() {
    this.dragOverItem = null;
  }

  onDrop() {
    this.dragItem = null;
    this.dragOverItem = null;
  }

  resetDrag() {
    this.dragItem = null;
    this.dragOverItem = null;
  }
}
