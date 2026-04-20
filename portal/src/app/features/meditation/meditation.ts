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
import { ICourseData } from '../../models/course-model';
import { CourseService } from '../../services/course-service';

@Component({
  selector: 'app-meditation',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog, Upload],
  templateUrl: './meditation.html',
  styleUrl: './meditation.css',
})
export class Meditation {
  rowCount = signal<number>(0);
  list = signal<IMeditationData[]>([]);
  course_list = signal<ICourseData[]>([]);
  loaderDialog = signal<boolean>(false);
  formDialog = signal<boolean>(false);
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
        if (formData.url!.length <= 0 && this.audioFile === null) {
          this.msg = 'Either upload file or provide url';
        }
        var fd = new FormData();
        let input: any = {
          courseid: formData.courseid,
          title: formData.title,
          url: formData.url!.length > 0 ? formData.url : null,
          audio: null,
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
        fd.append('map', JSON.stringify({ '0': ['variables.input.thumbnail'], '1': ['variables.input.audio'] }));
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
        this.show(this.loaderDialog);
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
        this.hide(this.loaderDialog);
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
    this.loaderDialog.set(true);
    this.titleService.title = 'Meditations';
    this.preview.set(
      this.sanitizer.bypassSecurityTrustResourceUrl('https://samplelib.com/mp3/sample-6s.mp3'),
    );
    let result = await this.course.list({});
    this.course_list.set(result?.rows!);
    await this.load({});
    this.loaderDialog.set(false);
  }

  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    if (result) {
      this.rowCount.set(result.count!);
      this.list.set(result.rows!);
    }
  }
  async showPlayer(id: string) {
    let row = this.list().find((x) => x.id === id);
    const url = this.sanitizer.bypassSecurityTrustResourceUrl(row?.url!);
    this.preview.set(url);
    this.playerDialog.set(true);
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
        this.dialogTitle.set('New Meditation Audio');
        me.set(true);
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);        
        this.thumbnail.set(row!?.thumbnail!);
        this.audio.set(row?.url!);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Meditation Audio');
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

  fileChange(type:'I' | 'A', $event: File | null) {
    switch(type){
      case 'I':        
        this.imageFile.set($event);        
        break;
      case 'A':        
        this.audioFile.set($event);        
        break;
    }
    
  }

  async delete(id: string): Promise<void> {
    this.show(this.loaderDialog);
    let result = await this.service.delete(id);
    this.hide(this.loaderDialog);
    this.load({});
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
