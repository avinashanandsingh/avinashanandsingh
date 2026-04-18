import { CommonModule, NgClass } from '@angular/common';
import { Component, computed, OnInit, signal } from '@angular/core';
import { form, FormField, required, submit } from '@angular/forms/signals';
import { ICategoryData, ICategoryForm } from '../../models/category';
import { ReactiveFormsModule } from '@angular/forms';
import { CategoryDialog } from './category-dialog/category-dialog';
import { CategoryService } from '../../services/category-service';
import Data from '../../models/data';
import Filter from '../../models/filter';

@Component({
  selector: 'app-category',
  imports: [CommonModule, NgClass, FormField, ReactiveFormsModule, CategoryDialog],
  templateUrl: './category.html',
  styleUrl: './category.css',
})
export class Category implements OnInit {
  list = signal<ICategoryData[]>([]);

  // Modal State
  showModal = signal<boolean>(false);
  isEditing = signal<boolean>(false);
  isLoading = signal<boolean>(false);
  error = signal<string>('');
  success = signal<boolean>(false);

  selectedFile = signal<File | null>(null);
  previewImage = signal<string | null>(null);
  dragActive = signal<boolean>(false);

  model = signal<ICategoryForm>({
    name: '',
    slug: '',
    description: '',
  });

  me = form(this.model, (schema) => {
    required(schema.name!, { message: 'Name of category is required' });
    required(schema.slug!);
  });
  nameError = computed(() => {
    const field = this.me.name();
    return field.touched() && field.invalid() ? field.errors().shift()?.message : null;
  });

  constructor(private service: CategoryService) {}
  async ngOnInit(): Promise<void> {
    await this.refresh({});
  }
  async refresh(filter: Filter) {
    let data: Data<ICategoryData> = await this.service.list(filter);
    if (data?.count! > 0) {
      this.list.set(data?.rows!);
    }else{
      this.list.set([]);
    }
  }
  async onSubmit(event: Event) {
    event.preventDefault();
    await submit(this.me, async (f: any) => {
      // 1. At this point all fields are already marked as touched
      // 2. If form is invalid - this function will NOT be called
      // 3. form().submitting() === true during execution
      let entity = this.model();
      if (!entity.name || !entity.slug) return;
      this.isLoading.set(true);
      this.error.set('');
      this.success.set(false);

      if (this.isEditing()) {
        const edit: ICategoryForm = {
          name: entity.name,
          description: entity.description,
          slug: entity.slug,
          icon: entity.icon,
        };
        let state = await this.service.update(entity.id!, edit);
        console.log(state);
      } else {
        // Add new
        const newCat: ICategoryForm = {
          name: entity.name,
          description: entity.description,
          slug: entity.slug,
          icon: entity.icon,
        };
        let state = await this.service.add(newCat);
        console.log(state);
      }
      await this.refresh({});
      this.isLoading.set(false);
      this.closeModal();

      return undefined; // success
    });
  }

  editCategory(cat: ICategoryData) {
    console.log(cat);
    let edit: ICategoryForm = {
      id: cat.id,
      name: cat.name,
      slug: cat.slug,
      description: cat.description,
    };
    if (cat.icon) {
      this.previewImage.set(cat.icon);
    }
    this.model.set(edit);
    this.isEditing.set(true);
    this.showModal.set(true);
  }

  async delete(id: string) {
    if (confirm('Are you sure you want to delete this category?')) {
      this.list.update((arr) => arr.filter((c) => c.id !== id));
      let rowid = await this.service.delete(id);
      if (rowid !== null) {
        alert('Catagory deleted successfully');
        await this.refresh({});
      }
    }
  }
  openModal() {
    this.showModal.set(true);
    if (!this.isEditing()) {
      let catg: ICategoryForm = {
        name: '',
        slug: '',
        description: '',
      };
      this.model.set(catg);
    }
    // Reset form data for new entries
    this.isEditing.set(false);
    this.isLoading.set(false);
  }

  closeModal() {
    this.showModal.set(false);
    this.me().reset();
    this.isEditing.set(false);
    this.isLoading.set(false);
    this.error.set('');
    this.success.set(false);
  }

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
    //const maxSize = 5 * 1024 * 1024; // 5MB
    const maxSize = 100 * 1024; // 100KB
    const allowedTypes = ['image/jpeg', 'image/png', 'image/svg+xml', 'image/gif', 'image/webp'];

    if (file.size > maxSize) {
      this.error.set('Image size must be less than 100KB');
      this.selectedFile.set(null);
      return;
    }

    if (!allowedTypes.includes(file.type)) {
      this.error.set('Only JPG, PNG, SVG, GIF, and WEBP images are allowed');
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
      this.previewImage.set(reader.result as string);
      console.log(reader.result);
      //.file!.content = reader.result as string;
      this.model().icon = {
        name: file.name,
        type: file.type,
        content: reader.result as string,
      };
      console.log(this.model());
    };
    reader.readAsDataURL(file);
  }

  // Clear image
  clearImage() {
    this.previewImage.set(null);
    this.selectedFile.set(null);
  }
}
