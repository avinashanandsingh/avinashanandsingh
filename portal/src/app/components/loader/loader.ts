import { Component, Input, signal } from '@angular/core';

@Component({
  selector: 'loader',
  imports: [],
  templateUrl: './loader.html',
  styleUrl: './loader.css',
})
export class Loader {
   @Input() isOpen = signal<boolean>(false);
}
