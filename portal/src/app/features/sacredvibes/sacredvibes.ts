import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { Loader } from '../../components/loader/loader';
import { CommonModule } from '@angular/common';
import { IScarevibeData } from '../../models/scarevibe';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import Filter from '../../models/filter';
import { SacredvibeService } from '../../services/sacredvibe-service';
import { Dialog } from '../../components/dialog/dialog';
import { Upload } from '../../components/upload/upload';
import { TitleService } from '../../services/title-service';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-scarevibes',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog, Upload],
  templateUrl: './sacredvibes.html',
  styleUrl: './sacredvibes.css',
})
export class Sacredvibes implements OnInit {
  rowCount = signal<number>(0);
  list = signal<IScarevibeData[]>([]);
  loaderDialog = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  playerDialog = signal<boolean>(false);
  preview = signal<SafeResourceUrl | null>(null);
  mode = signal<'ADD' | 'EDIT'>('ADD');
  dialogTitle = signal<string>('New Sacredvibe');
  dragItem: IScarevibeData | null = null;
  dragOverItem: IScarevibeData | null = null;
  file = signal<File | null>(null);
  msg?: string;
  form: FormGroup = new FormGroup({
    id: new FormControl(undefined),
    title: new FormControl('', [Validators.required]),
    duration: new FormControl('', [Validators.required]),
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
        if (formData.url?.length <= 0 && this.file === null) {
          this.msg = 'Either upload file or provide url';
        }
        var fd = new FormData();
        let input: any = {
          title: formData.title,
          duration: formData.duration,
          url: formData.url,
          file: null,
        };
        let body: any = {};
        if (formData.id) {
          console.log('edit: ', formData.id);
          body = {
            query:
              'mutation update ($id: UUID!, $input: SacredvibeIn!) { updateSacredvibe(id:$id, input: $input) { id } }',
            variables: {
              id: formData.id,
              input: {
                ...input,
              },
            },
          };
        } else {
          body = {
            query: 'mutation add ($input: SacredvibeIn!) { addSacredvibe(input: $input) { id } }',
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
            result = await this.service.save(fd);
            if (result?.data?.addSacredvibe) {
              Swal.fire({
                title: 'Success',
                html: 'Sacredvibe saved successfully',
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
            console.log('id: ', formData.id);
            result = await this.service.save(fd);
            if (result?.data?.updateSacredvibe) {
              Swal.fire({
                title: 'Success',
                html: 'Sacredvibe updated successfully',
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
        }
        this.load({});
        this.hide(this.loaderDialog);
        this.hide(this.formDialog);
      },
      type: 'btn btn-primary w-full',
    },
  ]);

  constructor(
    private service: SacredvibeService,
    private titleService: TitleService,
    private sanitizer: DomSanitizer,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Sacredvibes';
    this.preview.set(
      this.sanitizer.bypassSecurityTrustResourceUrl('https://samplelib.com/mp3/sample-6s.mp3'),
    );
    this.show(this.loaderDialog);
    await this.load({});
    this.hide(this.loaderDialog);
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
        this.dialogTitle.set('New Sacredvibe');
        me.set(true);
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);
        this.form.patchValue(row!);
        this.dialogTitle.set('Update Sacredvibe');
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

  fileChange($event: File | null) {
    this.file.set($event);
    console.log(this.file());
  }

  async delete(id: string): Promise<void> {
    this.show(this.loaderDialog);
    let result = await this.service.delete(id);
    this.hide(this.loaderDialog);
    this.load({});
  }

  // --- Drag and Drop Logic ---

  onDragStart(event: any, item: IScarevibeData) {
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
