import { CommonModule } from '@angular/common';
import {
  Component,
  EventEmitter,
  Input,
  OnChanges,
  OnInit,
  Output,
  signal,
  SimpleChanges,
} from '@angular/core';
import { ControlValueAccessor, NgControl } from '@angular/forms';

@Component({
  selector: 'date-picker',
  imports: [CommonModule],
  templateUrl: './date-picker.html',
  styleUrl: './date-picker.css',
})
export class DatePicker implements ControlValueAccessor, OnInit, OnChanges {
  @Input() placeholder = 'YYYY-MM-DD';
  @Input() minDate: Date | null = null;
  @Input() maxDate: Date | null = null;
  @Input() disabled = false;
  @Input() showHelperText = false;

  @Output() valueChange: EventEmitter<Date | null> = new EventEmitter<Date | null>();

  modelValue = signal<Date | null>(null);
  touched = false;
  showError = false;
  showCalendar = false;

  currentYear = new Date().getFullYear();
  currentMonth = new Date().getMonth();
  selectedDate = signal<Date | null>(null);

  weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  calendarDays: number[] = [];
  emptyDays: number[] = [];
  hasSelectedDate = false;

  private controlRef: NgControl | null = null;
  private onWriteValue: (value: Date | null) => void = () => {};
  private onTouched: () => void = () => {};

  ngOnInit() {
    if (this.modelValue) {
      this.selectedDate.set(this.modelValue());
      this.generateCalendar();
    }
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes['modelValue']) {
      this.modelValue = changes['modelValue'].currentValue || null;
     this.selectedDate.set(this.modelValue());
      this.generateCalendar();
    }
  }
  onChange($event: Event) {
    throw new Error('Method not implemented.');
  }
  onInput($event: Event) {
    throw new Error('Method not implemented.');
  }
  // Helper to get month name
  getMonthName(monthIndex: number): string {
    return (
      new Date().toLocaleString('default', { month: 'long' }).charAt(0).toUpperCase() +
      new Date().toLocaleString('default', { month: 'long' }).substring(1)
    );
  }

  // Generate calendar days
  generateCalendar(): void {
    // Get first day of current month
    const firstDayOfMonth = new Date(this.currentYear, this.currentMonth, 1);
    const lastDayOfMonth = new Date(this.currentYear, this.currentMonth + 1, 0);

    // Calculate empty days for first month
    this.emptyDays = Array.from({ length: firstDayOfMonth.getDay() }, (_, i) => i + 1);

    // Generate days for current month
    this.calendarDays = Array.from({ length: lastDayOfMonth.getDate() }, (_, i) => i + 1);

    // Update selected date
    this.hasSelectedDate = !!this.selectedDate;
  }

  // Toggle calendar
  toggleCalendar(): void {
    if (!this.showCalendar) {
      this.generateCalendar();
      this.showCalendar = true;
    }
  }

  // Close calendar
  closeCalendar(): void {
    this.showCalendar = false;
    this.selectedDate.set( null);
    this.hasSelectedDate = false;
    this.modelValue.set(null);
    this.valueChange.emit(null);
  }

  // Previous month
  prevMonth(): void {
    this.currentMonth--;
    if (this.currentMonth < 0) {
      this.currentMonth = 11;
      this.currentYear--;
    }
    this.generateCalendar();
  }

  // Next month
  nextMonth(): void {
    this.currentMonth++;
    if (this.currentMonth > 11) {
      this.currentMonth = 0;
      this.currentYear++;
    }
    this.generateCalendar();
  }

  // Select date
  selectDate(day: number): void {
    const selectedDate = new Date(this.currentYear, this.currentMonth, day);

    // Validate date range
    if (!this.isValidDate(selectedDate)) {
      return;
    }

    this.selectedDate.set(selectedDate);    
    this.modelValue.set(selectedDate);    
    this.valueChange.emit(selectedDate);
    this.showError = false;
    this.closeCalendar();
  }

  // Confirm date
  confirmDate(): void {
    if (!this.selectedDate) {
      this.closeCalendar();
      return;
    }

    this.modelValue.set(this.selectedDate());
    this.valueChange.emit(this.selectedDate());
    this.showError = false;
    this.closeCalendar();
  }

  // Get error message
  getErrorMessage(): string {
    if (!this.modelValue) {
      return 'Please select a date';
    }

    const [year, month, day] = this.modelValue()!.toISOString().split('T')[0].split('-');
    const dateStr = `${year}-${month}-${day}`;

    if (this.minDate && this.minDate > this.modelValue()!) {
      return `Date must be after ${this.minDate.toISOString().split('T')[0]}`;
    }

    if (this.maxDate && this.maxDate < this.modelValue()!) {
      return `Date must be before ${this.maxDate.toISOString().split('T')[0]}`;
    }

    return 'Invalid date';
  }

  // Check if date is valid
  isValidDate(date: Date): boolean {
    if (!date) return false;

    const dateStr = date.toISOString().split('T')[0];
    const formattedDateStr = dateStr.padStart(2, '0');

    const [minYear, minMonth, minDay] = this.minDate?.toISOString().split('T')[0].split('-') || [
      '9999',
      '12',
      '31',
    ];
    const [maxYear, maxMonth, maxDay] = this.maxDate?.toISOString().split('T')[0].split('-') || [
      '0000',
      '01',
      '01',
    ];

    const minDate = `${minYear}-${parseInt(minMonth).toString().padStart(2, '0')}-${parseInt(minDay).toString().padStart(2, '0')}`;
    const maxDate = `${maxYear}-${parseInt(maxMonth).toString().padStart(2, '0')}-${parseInt(maxDay).toString().padStart(2, '0')}`;

    if (this.minDate && dateStr < minDate) return false;
    if (this.maxDate && dateStr > maxDate) return false;

    return true;
  }

  // Check if day is disabled
  isDayDisabled(day: number): boolean {
    if (this.minDate && this.selectedDate) {
      const selectedDate = new Date(
        this.selectedDate()?.getFullYear()!,
        this.selectedDate()?.getMonth()!,
        day,
      );
      if (selectedDate < this.minDate) return true;
    }

    if (this.maxDate && this.selectedDate) {
      const selectedDate = new Date(
        this.selectedDate()?.getFullYear()!,
        this.selectedDate()?.getMonth()!,
        day,
      );
      if (selectedDate > this.maxDate) return true;
    }

    return false;
  }

  // Convert date to string
  getDateString(date: Date | null): string {
    if (!date) return '';
    return date.toISOString().split('T')[0];
  }

  // Write value from form control
  writeValue(value: Date | null): void {
    if (value) {
      this.modelValue.set(new Date(value));
      this.selectedDate.set(this.modelValue());
      this.generateCalendar();
    } else {
      this.modelValue.set(null);
      this.selectedDate.set(null);
    }
  }

  // Register on change
  registerOnChange(fn: any): void {
    this.onWriteValue = fn;
  }

  // Register on touched
  registerOnTouched(fn: any): void {
    this.onTouched = fn;
  }

  // Set disabled state
  setDisabledState(enabled: boolean): void {
    this.disabled = enabled;
  }
}
