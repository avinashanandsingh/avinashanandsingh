import { CommonModule } from '@angular/common';
import { Component, signal, WritableSignal } from '@angular/core';
import { Upload } from '../../components/upload/upload';
import { Dialog } from '../../components/dialog/dialog';
import { ShortService } from '../../services/short-service';
import { Loader } from '../../components/loader/loader';
import { IShortData } from '../../models/short';
import Filter from '../../models/filter';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import Swal from 'sweetalert2';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { TitleService } from '../../services/title-service';

// --- Interface ---
interface Video {
  id: string;
  title: string;
  description: string;
  thumbnailUrl: string; // We'll use a placeholder or FileReader
  videoUrl: string;
  views: number;
  likes: number;
  uploadedAt: Date;
  duration: string; // e.g. "0:30"
}

@Component({
  selector: 'app-shorts',
  imports: [CommonModule, Upload, Dialog, Loader, ReactiveFormsModule],
  templateUrl: './shorts.html',
  styleUrl: './shorts.css',
})
export class Shorts {
  // --- State ---
  videos: Video[] = [];
  list = signal<IShortData[]>([]);
  isPlayerOpen = signal<boolean>(false);
  isEditorOpen = signal<boolean>(false);
  loaderDialog = signal<boolean>(false);
  thumbnail = signal<File | null>(null);
  video = signal<File | null>(null);
  preview = signal<SafeResourceUrl | null>(null);
  thumbnailUrl = signal<string>('');
  videoUrl = signal<string | null>(null);
  selectedVideo: Video | null = null;
  error = signal<string>('');
  selectedFile = signal<File | null>(null);
  // Dialog Mode: 'play' | 'edit' | 'new'
  mode = signal<'PLAY' | 'EDIT' | 'ADD'>('ADD');
  dialogTitle = signal<string>('');
  allowedImageTypes = ['image/png', 'image/jpeg', 'image/gif', 'image/webp', 'image/svg+xml'];
  allowedVideoTypes = ['video/mp4', 'video/webm'];
  uploadProgress = 0;
  isUploading = false;
  dragActive = signal<boolean>(false);

  form: FormGroup = new FormGroup({
    id: new FormControl(undefined),
    title: new FormControl('', [Validators.required]),
    url: new FormControl(''),
  });

  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        //this.form.reset();
        this.hide(this.isEditorOpen);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        if (this.form.invalid) return;
        let formData = this.form.getRawValue();

        if (formData.url!.length <= 0 && this.video() === null) {
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
          title: formData.title,
          url: formData.url!.length > 0 ? formData.url : null,
          thumbnail: null,
          video: null,
        };
        let body: any = {};
        if (formData.id) {
          console.log('edit: ', formData.id);
          body = {
            query:
              'mutation update ($id: UUID!, $input: ShortIn!) { updateShort(id:$id, input: $input) { id } }',
            variables: {
              id: formData.id,
              input: {
                ...input,
              },
            },
          };
        } else {
          body = {
            query: 'mutation add ($input: ShortIn!) { addShort(input: $input) { id } }',
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
          fd.append('0', this.thumbnail()!, this.thumbnail()!.name);
        } else {
          fd.append('0', '');
        }

        if (this.video()) {
          fd.append('1', this.video()!, this.video()!.name);
        } else {
          fd.append('1', '');
        }

        let result: any;
        this.show(this.loaderDialog);
        switch (this.mode()) {
          case 'ADD':
            result = await this.service.saveFormData(fd);
            if (result?.data?.addShort) {
              Swal.fire({
                title: 'Success',
                html: 'Short saved successfully',
                icon: 'success',
                timer: 3000,
              });
            }
            break;
          case 'EDIT':
            console.log('id: ', formData.id);
            result = await this.service.saveFormData(fd);
            if (result?.data?.updateShort) {
              Swal.fire({
                title: 'Success',
                html: 'Short updated successfully',
                icon: 'success',
                timer: 3000,
              });
            }
            break;
        }
        this.load({});
        this.form.reset();
        this.hide(this.loaderDialog);
        this.hide(this.isEditorOpen);
      },
      type: 'btn btn-primary w-full',
    },
  ]);
  constructor(
    private service: ShortService,
    private titleService: TitleService,
    private sanitizer: DomSanitizer,
  ) {}
  // --- Methods ---
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Shorts';
    this.show(this.loaderDialog);
    await this.load({});
    this.hide(this.loaderDialog);
  }

  ngOnDestroy(): void {
    this.videos.forEach((v) => URL.revokeObjectURL(v.thumbnailUrl));
  }
  async load(filter: Filter) {
    let result = await this.service.list(filter);
    if (result) {
      this.list.set(result?.rows!);
    }
  }

  // --- Open Actions ---
  show(me: WritableSignal<boolean>, mode?: 'PLAY' | 'EDIT' | 'ADD', id?: string) {
    if (mode) {
      this.mode.set(mode);
      switch (mode) {
        case 'PLAY':
          this.dialogTitle.set('Watch Video');
          let row = this.list().find((x) => x.id === id);
          if (row) {
            let url = this.sanitizer.bypassSecurityTrustResourceUrl(row?.url!);
            this.preview.set(url);
          }
          break;
        case 'ADD':
          this.dialogTitle.set('Add New Short');
          break;
        case 'EDIT':
          let erow = this.list().find((x) => x.id === id);
          this.thumbnailUrl.set(erow!.thumbnail);
          this.videoUrl.set(erow?.url!);
          this.form.patchValue(erow!);
          this.dialogTitle.set('Update Short');
          break;
      }
    }
    me.set(true);
  }

  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }

  // --- Edit Logic ---
  completeHandler(type: 'I' | 'V', $event: File | null) {
    if (type === 'I') {
      this.thumbnail.set($event);
    } else if (type === 'V') {
      this.video.set($event);
    }
  }

  async delete(id: string): Promise<void> {
    if (confirm('Are you sure you want to delete this short?')) {
      this.show(this.loaderDialog);
      let result = await this.service.delete(id);
      if (result) {
        await this.load({});
      }
      this.hide(this.loaderDialog);
    }
  }

  /* Upload Section */
  async handleFileInput(event: Event): Promise<void> {
    const target = event.target as HTMLInputElement;
    const file = target.files?.[0];
    if (file) {
      this.validateFile(file);
      this.readFile(file);
    }
  }

  handleFileDrop(event: DragEvent) {
    event.preventDefault();
    const files = event.dataTransfer!.files;

    if (files.length > 0) {
      this.validateFile(files[0]);
      this.readFile(files[0]);
    }
  }

  handleDragOver(event: DragEvent) {
    event.preventDefault();
    event.stopPropagation();
    this.dragActive.set(true);
  }

  handleDragLeave(event: DragEvent) {
    event.preventDefault();
    event.stopPropagation();
    this.dragActive.set(false);
  }

  // Validate file size and type
  validateFile(file: File) {
    const maxSize = 25 * 1024 * 1024; // 25MB
    const allowedTypes = ['video/mp4'];

    if (file.size > maxSize) {
      this.error.set('Video size must be less than 25MB');
      this.selectedFile.set(null);
      return;
    }

    if (!allowedTypes.includes(file.type)) {
      this.error.set('Only MP4 videos are allowed');
      this.selectedFile.set(null);
      return;
    }

    this.error.set('');
    this.selectedFile.set(file);
  }

  // Read and preview file
  readFile(file: File) {
    const reader = new FileReader();
    reader.onload = () => {
      console.log(file.name, file.type, reader.result);
    };
    reader.readAsDataURL(file);
  }
}
