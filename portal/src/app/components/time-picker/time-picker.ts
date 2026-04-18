import { CommonModule } from '@angular/common';
import {
  Component,
  EventEmitter,
  Input,
  OnChanges,
  OnInit,
  Output,
  SimpleChanges,
} from '@angular/core';
import { ControlValueAccessor, NgControl, ɵInternalFormsSharedModule } from '@angular/forms';

@Component({
  selector: 'time-picker',
  imports: [CommonModule, ɵInternalFormsSharedModule],
  templateUrl: './time-picker.html',
  styleUrl: './time-picker.css',
})
export class TimePicker implements OnInit, ControlValueAccessor, OnChanges {
  @Input() placeholder = 'HH:MM';
  @Input() required = true;
  @Input() editable = true;
  @Input() disabled = false;
  @Input() minTime: string = '00:00';
  @Input() maxTime: string = '23:59';  
  @Output() valueChange: EventEmitter<string> = new EventEmitter<string>();

  modelValue?: string;
  touched = false;
  showError = false;
  showPicker = false;
  hour?: string;
  minute?: string;

  hours: string[] = [];
  minutes: string[] = [];
  selectedHour: number = 0;
  selectedMinutes: number = 0;
  errorMessages: { [key: string]: string } = {};
  private controlRef: NgControl | null = null;
  //hour: number = 0;
  time?: string[] = [];
at?:string;
  ngOnInit() {
    // Set the value if there's a pre-existing value
    this.modelValue = this.controlRef?.value || '';
    this.generatePickerData();
  }

  ngOnChanges(changes: SimpleChanges) {
    if (changes['modelValue']) {
      this.modelValue = changes['modelValue'].currentValue || '';
    }
  }

  change(e: any, type: 'HH' | 'MM' | 'AMPM') {
    console.log(e);
    switch (type) {
      case 'HH':
        this.hour = e.target.value.toString().padStart(2,'0');
        break;
      case 'MM':
        this.minute = e.target.value.toString().padStart(2,'0');
        this.time?.push(':');
        this.time?.push(e.target.value.toString().padStart(2,'0'));
        break;
      case 'AMPM':
        this.at = e.target.value;
        break;
    }
    let value: string = '';
    if (this.hour!.trim().length > 0) {
      value += this.hour;
    }
    if (this.minute?.trim()!.length! > 0) {
      value += `:${this.minute}`;
    }
    if (this.at?.trim()!.length! > 0) {
      value += ` ${this.at}`;
    }
    this.valueChange.emit(value);
  }

  // Get control name from NgControl
  getControlName(): any {
    return this.controlRef?.name!;
  }

  // Get control errors from NgControl
  getControlErrors(): boolean {
    return (
      (this.controlRef?.invalid && this.controlRef?.touched) || this.controlRef?.disabled || false
    );
  }

  // Get error message
  getErrorMessages(): { [key: string]: string } {
    return {
      required: 'Time is required',
      minTime: 'Minimum time: {{ minTime }}',
      maxTime: 'Maximum time: {{ maxTime }}',
      invalidFormat: 'Please use HH:MM format',
    };
  }

  onInput(event: Event): void {
    if (this.editable) {
      const value = (event.target as HTMLInputElement).value;
      this.modelValue = value;
      this.valueChange.emit(value);
      this.showError = !this.validate(value);
    }
  }

  onChange(event: Event): void {
    if (this.editable) {
      this.modelValue = (event.target as HTMLInputElement).value;
      this.valueChange.emit(this.modelValue);
      this.showError = !this.validate(this.modelValue);
    }
  }

  validate(time: string): boolean {
    if (!time) return false;
    if (!/^\d{2}:\d{2}$/.test(time)) return false;

    const [hour, minute] = time.split(':').map(Number);
    const timeMinutes = hour * 60 + minute;

    if (this.minTime) {
      const [minHour, minMinute] = this.minTime.split(':').map(Number);
      const minMinutes = minHour * 60 + minMinute;
      if (timeMinutes < minMinutes) return false;
    }

    if (this.maxTime) {
      const [maxHour, maxMinute] = this.maxTime.split(':').map(Number);
      const maxMinutes = maxHour * 60 + maxMinute;
      if (timeMinutes > maxMinutes) return false;
    }

    return true;
  }

  selectHour(hour: number): void {
    this.selectedHour = hour;
    this.selectedMinutes = this.minutes.length > 0 ? 0 : 30;
    this.generatePickerData();
  }

  selectHourAndMinute(hour: number, minute: number): void {
    this.selectedHour = hour;
    this.selectedMinutes = minute;
    this.modelValue = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
    this.valueChange.emit(this.modelValue);
    this.showError = false;
    setTimeout(() => this.closePicker(), 300);
  }

  formatHour(hour: number): string {
    if (hour === 0) return '12';
    const ampm = hour < 12 ? 'AM' : 'PM';
    let displayHour = hour;
    if (hour === 0) displayHour = 12;
    if (hour > 12) displayHour -= 12;
    return `${displayHour} ${ampm}`;
  }

  formatMinute(minute: number): string {
    return `${minute.toString().padStart(2, '0')}`;
  }

  confirmTime(): void {
    const time = `${this.selectedHour}:${this.selectedMinutes}`;
    if (this.validate(time)) {
      this.modelValue = time;
      this.valueChange.emit(time);
      this.showError = false;
      this.closePicker();
    }
  }

  closePicker(): void {
    this.showPicker = false;
    this.selectedHour = 0;
    this.selectedMinutes = 0;
  }

  writeValue(value: string | null): void {
    if (value) {
      this.modelValue = value;
    }
  }

  registerOnChange(fn: any): void {
    // Value is managed via @Output()
  }

  registerOnTouched(fn: any): void {
    this.onTouched = fn;
  }

  setDisabledState(enabled: boolean): void {
    this.disabled = enabled;
    this.editable = !enabled;
  }

  onTouched: () => void = () => {};

  generatePickerData(): void {
    this.hours = Array.from({ length: 24 }, (_, i) => i.toString());
    this.minutes = Array.from({ length: 12 }, (_, i) => (i * 5).toString());
  }

  // Access NgControl to get form control errors
  setControlRef(controlRef: NgControl): void {
    this.controlRef = controlRef;
  }
}
