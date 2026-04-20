import {
  AfterViewInit,
  Component,
  ElementRef,
  EventEmitter,
  Output,
  ViewChild,
} from '@angular/core';
import { FormControl } from '@angular/forms';

@Component({
  selector: 'otp',
  imports: [],
  templateUrl: './otp.html',
  styleUrl: './otp.css',
})
export class Otp implements AfterViewInit {
  @ViewChild('one') irOne!: ElementRef;
  @Output() onOtpChange = new EventEmitter<string>();
  one = new FormControl('');
  two = new FormControl('');
  three = new FormControl('');
  four = new FormControl('');
  five = new FormControl('');
  six = new FormControl('');
  otp: string[] = [];
  ngAfterViewInit(): void {
    this.irOne.nativeElement.focus();
  }

  onKeyUp($event: any) {
    let el = $event.target as HTMLInputElement;
    let key = $event.key;
    let nums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    if (nums.includes(Number(key))) {
      this.otp.push(key);
      switch (el.id) {
        case 'one':
          el = document.querySelector('#two') as HTMLInputElement;
          el.focus();
          break;
        case 'two':
          el = document.querySelector('#three') as HTMLInputElement;
          el.focus();
          break;
        case 'three':
          el = document.querySelector('#four') as HTMLInputElement;
          el.focus();
          break;
        case 'four':
          el = document.querySelector('#five') as HTMLInputElement;
          el.focus();
          break;
        case 'five':
          el = document.querySelector('#six') as HTMLInputElement;
          el.focus();
          break;
      }
    } else if (key === 'Backspace') {
      switch (el.id) {
        case 'two':
          el = document.querySelector('#one') as HTMLInputElement;
          el.focus();
          break;
        case 'three':
          el = document.querySelector('#two') as HTMLInputElement;
          el.focus();
          break;
        case 'four':
          el = document.querySelector('#three') as HTMLInputElement;
          el.focus();
          break;
        case 'five':
          el = document.querySelector('#four') as HTMLInputElement;
          el.focus();
          break;
        case 'six':
          el = document.querySelector('#five') as HTMLInputElement;
          el.focus();
          break;
      }
    }
  }
  onChange() {
    this.onOtpChange.emit(this.otp.join(''));
  }
}
