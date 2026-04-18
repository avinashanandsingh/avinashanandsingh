import { Component, signal, WritableSignal } from '@angular/core';
import { TitleService } from '../../services/title-service';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { MeditationService } from '../../services/meditation-service';
import { IMeditationData } from '../../models/meditation';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Loader } from "../../components/loader/loader";
import Filter from '../../models/filter';
import { CommonModule } from '@angular/common';
import { Dialog } from '../../components/dialog/dialog';
import { Upload } from "../../components/upload/upload";

@Component({
  selector: 'app-meditation',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog, Upload],
  templateUrl: './meditation.html',
  styleUrl: './meditation.css',
})
export class Meditation {
  rowCount = signal<number>(0);
    list = signal<IMeditationData[]>([]);
    loaderDialog = signal<boolean>(false);
    formDialog = signal<boolean>(false);
    playerDialog =signal<boolean>(false);
    preview = signal<SafeResourceUrl | null>(null);
    mode = signal<'ADD' | 'EDIT'>('ADD');
    dialogTitle = signal<string>('Add New Resource');
    dragItem: IMeditationData | null = null;
    dragOverItem: IMeditationData | null = null;
    file = signal<File | null>(null);
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
          if (formData.url!.length <= 0 && this.file === null) {
            this.msg = 'Either upload file or provide url';
          }
          var fd = new FormData();
          let input: any = {        
            title: formData.title,
            url: formData.url!.length > 0 ? formData.url : null,
            file: null,
          };
          let body: any = {};
          if (formData.id) {
            console.log('edit: ', formData.id);
            body = {
              query:
                'mutation update ($id: UUID!, $input: ScaredvibeIn!) { updateScaredvibe(id:$id, input: $input) { id } }',
              variables: {
                id: formData.id,
                input: {
                  ...input,
                },
              },
            };
          } else {
            body = {
              query: 'mutation add ($input: ScaredvibeIn!) { addScaredvibe(input: $input) { id } }',
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
              if (result?.data?.addScaredvibe) {
                alert('Resource saved successfully');
              }
              break;
            case 'EDIT':
              console.log('id: ', formData.id);
              result = await this.service.save(fd);
              if (result?.data?.updateScaredvibe) {
                alert('Resource updated successfully');
              }
              break;
          }
          this.hide(this.loaderDialog);
          this.hide(this.formDialog);
        },
        type: 'btn btn-primary w-full',
      },
    ]);
  
    constructor(
      private service: MeditationService,
      private titleService: TitleService,
      private sanitizer: DomSanitizer,
    ) {}
    async ngOnInit(): Promise<void> {
      this.titleService.title = 'Meditations';
      this.preview.set(this.sanitizer.bypassSecurityTrustResourceUrl('https://samplelib.com/mp3/sample-6s.mp3'));
      
      await this.load({});
    }
  
    async load(filter: Filter): Promise<void> {
      let result = await this.service.list(filter);
      if (result) {
        this.rowCount.set(result.count!);
        this.list.set(result.rows!);
      }
    }
    async showPlayer(id:string){
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
          this.dialogTitle.set('New Scarevibe');
          me.set(true);
          break;
        case 'EDIT':
          let row = this.list().find((x) => x.id === id);
          this.form.patchValue(row!);
          this.dialogTitle.set('Update Scarevibe');
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
