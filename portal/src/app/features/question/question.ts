import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import Filter from '../../models/filter';
import { IAuraData } from '../../models/aura';
import { CommonModule } from '@angular/common';
import { Loader } from '../../components/loader/loader';
import { Dialog } from '../../components/dialog/dialog';
import {
  FormArray,
  FormBuilder,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import Swal from 'sweetalert2';
import { TitleService } from '../../services/title-service';
import { QuestionService } from '../../services/question-service';
import { IOptionData, IQuestionData } from '../../models/question';
import { CourseService } from '../../services/course-service';
import { ICourseData } from '../../models/course-model';

@Component({
  selector: 'app-aura',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog],
  templateUrl: './question.html',
  styleUrl: './question.css',
})
export class Question implements OnInit {
  list = signal<IQuestionData[]>([]);
  course_list = signal<ICourseData[]>([]);
  typelist = signal<{ name: string; value: string }[]>([]);
  loader = signal<boolean>(false);
  formDialog = signal<boolean>(false);
  mode = signal<'ADD' | 'EDIT' | null>(null);
  file = signal<File | null>(null);
  dialogTitle = signal<string>('New Service');
  parentForm: FormGroup;

  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Close',
      action: () => {
        this.parentForm.reset();
        this.hide(this.formDialog);
      },
      type: 'btn btn-secondary w-full',
    },
    {
      label: 'Save',
      action: async () => {
        if (this.parentForm.invalid) return;
        let formData = this.parentForm.getRawValue();
        formData.options = formData.options.map((x: any) => {
          return {
            title: x.title,
            sort: Number(x.sort),
          };
        });
        let body: IQuestionData = {
          ...formData,
        };

        let result: any;
        this.show(this.loader);
        if (formData.id) {
          result = await this.service.update(body);
          if (result?.data?.updateQuestion) {
            Swal.fire({
              title: 'Success',
              html: 'Question updated successfully',
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
          result = await this.service.add(body);
          if (result?.data?.newQuestion) {
            Swal.fire({
              title: 'Success',
              html: 'Question saved successfully',
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
        this.hide(this.formDialog);
        await this.load({});
        this.hide(this.loader);
      },
      type: 'btn btn-primary w-full',
    },
  ]);

  expandedRowId = signal<string | null>(null);

  constructor(
    private service: QuestionService,
    private course: CourseService,
    private titleService: TitleService,
    private fb: FormBuilder,
  ) {
    this.parentForm = new FormGroup({
      id: new FormControl(undefined),
      courseid: new FormControl('', [Validators.required]),
      type: new FormControl('', [Validators.required]),
      title: new FormControl('', [Validators.required]),
      description: new FormControl(''),
      options: this.fb.array([]),
    });
  }
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Enrolment Q&A';
    if (this.options.length == 0) {
      const row = this.fb.group({
        title: ['', Validators.required],
        sort: ['', Validators.required],
      });
      this.options.push(row);
    }
    this.show(this.loader);
    let result: any = await this.course.list({});
    this.course_list.set(result?.rows ?? []);
    result = await this.service.typelist();
    this.typelist.set(result ?? []);
    await this.load({});
    this.hide(this.loader);
  }

  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    this.list.set(result?.rows! ?? []);
  }
  get options(): FormArray {
    return this.parentForm.get('options') as FormArray;
  }

  setItems(items: any[]) {
    const itemArray = this.parentForm.get('options') as FormArray;

    // 1. Clear existing items
    itemArray.clear();

    // 2. Loop through new data and push new groups
    items
      .sort((a, b) => a.sort - b.sort)
      .forEach((item) => {
        itemArray.push(
          this.fb.group({
            title: ['', Validators.required],
            sort: ['', Validators.required],
          }),
        );
      });

    // 3. Now patch the values
    itemArray.patchValue(items);
  }

  sorted_option(options: IOptionData[]): IOptionData[] {
    // Sort by price numerically (ascending)
    return options.sort((a, b) => a.sort! - b.sort!);
  }
  addRow() {
    const row = this.fb.group({
      title: ['', Validators.required],
      sort: ['', Validators.required],
    });
    this.options.push(row);
  }

  removeRow(index: number) {
    this.options.removeAt(index);
  }
  async show(me: WritableSignal<boolean>, mode?: 'ADD' | 'EDIT', id?: string) {
    if (this.mode) {
      this.mode.set(mode!);
    }
    switch (mode!) {
      case 'ADD':
        this.parentForm.reset({ courseid: '', type: '' });
        this.dialogTitle.set('New Question');
        break;
      case 'EDIT':
        let row = this.list().find((x) => x.id === id);
        this.parentForm.patchValue(row!);
        console.log(row?.options!);
        this.setItems(row?.options!);
        this.dialogTitle.set('Update Question');
        break;
    }
    me.set(true);
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
    //this.form.reset();
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
        await this.load({});
        this.hide(this.loader);
      }
    }
  }

  toggleRow(id: string) {
    this.expandedRowId.update((currentId) => (currentId === id ? null : id));
  }
}
