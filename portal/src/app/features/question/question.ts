import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import Filter from '../../models/filter';
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
import { ICourseData } from '../../models/course';
import { Pager } from '../../components/pager/pager';
import Criteria from '../../models/criteria';

@Component({
  selector: 'app-aura',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog, Pager],
  templateUrl: './question.html',
  styleUrl: './question.css',
})
export class Question implements OnInit {
  limit: number = Number(import.meta.env.NG_APP_LIMIT);
  offset: number = 0;
  total = signal<number>(0);
  criteria = signal<Criteria[]>([]);
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
        console.log(this.parentForm.invalid);
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
        await this.load({
          criteria: this.criteria(),
          offset: this.offset,
          limit: this.limit,
        });
        this.hide(this.loader);
      },
      type: 'btn btn-primary w-full',
    },
  ]);

  expandedRowId = signal<string | null>(null);
  type = signal<string>('');
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
    this.show(this.loader);
    let result: any = await this.course.list({});
    this.course_list.set(result?.rows ?? []);
    result = await this.service.typelist();
    this.typelist.set(result ?? []);
    await this.load({
      criteria: this.criteria(),
      offset: this.offset,
      limit: this.limit,
    });
    this.hide(this.loader);
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
  
  get options(): FormArray {
    return this.parentForm.get('options') as FormArray;
  }

  typeChange($event: Event) {
    let type = ($event.target as HTMLInputElement).value;
    console.log('type:', type);
    this.type.set(type);
    if (type !== 'Open Ended') {
      if (this.options.length == 0) {
        const row = this.fb.group({
          title: ['', Validators.required],
          sort: ['', Validators.required],
        });
        this.options.push(row);
      }
    } else {
      this.options.clear();
    }
  }

  setItems(items: any[]) {
    const itemArray = this.parentForm.get('options') as FormArray;

    // 1. Clear existing items
    itemArray.clear();

    // 2. Loop through new data and push new groups
    items
      .sort((a, b) => a.sort - b.sort)
      .forEach((item) => {
        if (this.type() !== 'Open Ended') {
          itemArray.push(
            this.fb.group({
              title: ['', Validators.required],
              sort: ['', Validators.required],
            }),
          );
        }
      });

    // 3. Now patch the values
    itemArray.patchValue(items);
  }

  sorted_option(options: IOptionData[]): IOptionData[] {
    // Sort by price numerically (ascending)
    return options.sort((a, b) => a.sort! - b.sort!);
  }
  addRow() {
    if (this.type() !== 'Open Ended') {
      const row = this.fb.group({
        title: ['', Validators.required],
        sort: ['', Validators.required],
      });
      this.options.push(row);
    }
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
      if (result?.data?.deleteQuestion) {
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
  }

  toggleRow(id: string) {
    this.expandedRowId.update((currentId) => (currentId === id ? null : id));
  }
}
