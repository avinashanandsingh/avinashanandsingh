import {
  Component,
  EventEmitter,
  Input,
  OnChanges,
  Output,
  signal,
  SimpleChanges,
} from '@angular/core';
import { IAutocompleteConfig, IAutocompleteItem } from '../../models/autocomplete';
import { form, FormField } from '@angular/forms/signals';
import { CommonModule, NgClass } from '@angular/common';

@Component({
  selector: 'app-autocomplete',
  imports: [CommonModule, FormField, NgClass],
  templateUrl: './autocomplete.html',
  styleUrl: './autocomplete.css',
})
export class Autocomplete implements OnChanges {
  // --- Input Signals ---
  @Input() config!: IAutocompleteConfig;
  @Input() searchItems!: (searchTerm: string) => Promise<IAutocompleteItem[]>;
  @Input() filterOptions!: { field: string; value: string }[];
  @Input() items!: IAutocompleteItem[];
  @Input() clearButtonMode?: 'always' | 'focus';

  // --- Output Signals ---
  @Output() selected = new EventEmitter<IAutocompleteItem>();
  @Output() searchChange = new EventEmitter<string>();

  // --- State Signals ---
  searchValue = signal<string>('');
  filteredItems = signal<IAutocompleteItem[]>([]);
  showDropdown = signal<boolean>(false);
  isLoading = signal<boolean>(false);
  errorMessage = signal<string>('');
  selectedId = signal<string | number | null>(null);
  selectedLabel = signal<string>('');
  focusedItemIndex = signal<number>(-1);

  searchModel = signal({
    search: '',
  });

  searchForm = form(this.searchModel);
  term:string = '';
  constructor() {
    // Initialize with provided items
    this.filteredItems.set(this.items);  
  }
  // --- Private Methods ---

  ngOnChanges(changes: SimpleChanges) {
    if (changes['items']) {
      this.updateFilteredItems();
    }
  }

  updateFilteredItems() {
    const opts = this.filterOptions || ([] as any[]);
    const currentFilter = opts.find((f) => f.field === 'status')?.value;
    this.filteredItems.set(
      this.items.filter((item) => (currentFilter ? item.status === currentFilter : true)),
    );
  }

  openDropdown() {
    this.showDropdown.set(true);
    //this.searchValue.set('');

    this.searchForm().value.set({ search: '' });
    this.filterOptions = this.items.map((_, index) => ({ field: 'status', value: 'active' }));
    //this.search();
  }

  closeDropdown() {
    this.showDropdown.set(false);
    this.selectedId.set(null);
    this.selectedLabel.set('');
  }

  inputHandler(event: Event) {
    const input = event.target as HTMLInputElement;
    const value = input.value;
    this.searchForm.search().value.set(value);
    //this.searchValue.set(value);
    this.searchChange.emit(value);

    // Reset search when clicking outside
    if (value === '') {
      this.filteredItems.set([]);
      this.showDropdown.set(false);
    } else {
      this.filteredItems.set([]);
      this.showDropdown.set(false);
    }
    this.searchItems(value).then((results) => {
      this.isLoading.set(false);
      this.filteredItems.set(results);
      this.showDropdown.set(results.length > 0);
    });
  }

  // Search Logic with Debouncing
  /* search() {
    //if (this.filteredItems().length === 0) return;

    const term = this.searchForm.search().value();
    if (term.length < this.config.minLength! || !term) {
      this.filteredItems.set(
        this.items.filter((item: any) =>
          this.filterOptions.every((f) => item[f.field] === f.value),
        ),
      );
      let value = this.searchForm.search().value;
      this.showDropdown.set(value.length === 0 || this.filterOptions.length > 0);
      return;
    }

    // Debounce for async search
    this.isLoading.set(true);
    this.errorMessage.set('');

    // Simulate API call or filter local items
    this.searchItems(this.term).then((results) => {
      this.isLoading.set(false);
      this.filteredItems.set(results);
      this.showDropdown.set(results.length > 0);
    });
  } */

  selectItem(item: IAutocompleteItem) {
    this.selected.emit(item);
    this.selectedId.set(item.id);
    this.selectedLabel.set(item.label);
    // this.searchValue.set(item.label);
    this.searchForm().value.set({ search: item.label });
    this.closeDropdown();
  }

  navigateDropdown(direction: 'up' | 'down') {
    const items = this.filteredItems();
    if (items.length === 0) return;

    if (direction === 'down') {
      this.focusedItemIndex.set(Math.min(this.focusedItemIndex() + 1, items.length - 1));
    } else {
      this.focusedItemIndex.set(Math.max(this.focusedItemIndex() - 1, 0));
    }
  }

  handleKeyDown(event: KeyboardEvent) {
    const keys = {
      ArrowUp: 'up',
      ArrowDown: 'down',
      Escape: 'close',
      Enter: 'select',
    };

    if (keys[event.key as keyof typeof keys]) {
      event.preventDefault();
      if (keys[event.key as keyof typeof keys] === 'close') {
        this.closeDropdown();
      } else if (keys[event.key as keyof typeof keys] === 'select') {
        this.selectItem(this.filteredItems()[this.focusedItemIndex()]);
      } else {
        this.navigateDropdown(keys[event.key as keyof typeof keys] as 'up' | 'down');
      }
    }
  }

  clearSelection() {
    this.searchForm.search().value.set('');
    //this.searchValue.set('');
    this.selectedId.set(null);
    this.selectedLabel.set('');
    this.closeDropdown();
  }

  // Format label with status if enabled
  formatLabel(item: IAutocompleteItem): string {
    //if (this.config.showStatus) {
     // const statusText = item.status ? ` • ${item.status.toUpperCase()}` : '';
      //return `${item.label}`;
    //}
    return item.label;
  }

  // Clear button visibility
  showClearButton() {
    if (this.clearButtonMode === 'always') return true;
    return this.searchForm.search().value() !== '';
  }
}
function effert(arg0: () => void) {
  throw new Error('Function not implemented.');
}

