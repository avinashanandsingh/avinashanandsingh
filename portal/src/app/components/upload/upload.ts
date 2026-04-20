import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, OnInit, Output, signal } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';

@Component({
  selector: 'app-upload',
  imports: [CommonModule],
  templateUrl: './upload.html',
  styleUrl: './upload.css',
})
export class Upload implements OnInit {
  blobUrl: string | null = null;

  // Input: Define the accepted file types (e.g., 'image/*', 'application/pdf')
  @Input({ required: true }) fileType: string = 'image/*';
  @Input() previewUrl?: string;
  safeUrl = signal<SafeResourceUrl | null>(null);
  // Output: Emit an event when a file is selected
  @Output() fileChange: EventEmitter<File | null> = new EventEmitter<File | null>();
  @Output() onPreviewChange: EventEmitter<string | null> = new EventEmitter<string | null>();

  // Optional: Label text inside the component
  @Input({ required: false }) labelText: string = 'Drop file or click to upload';
  fileName = signal<string>('');

  constructor( private sanitizer: DomSanitizer){
   
  }
  ngOnInit(): void {
    console.log(this.previewUrl);
     let url = this.sanitizer.bypassSecurityTrustResourceUrl(this.previewUrl!);    
    this.safeUrl.set(url!);
  }
  // Handle file change logic
  onFileSelected(event: Event): void {
    const target = event.target as HTMLInputElement;

    if (target.files && target.files.length > 0) {
      const file = target.files[0];
      this.fileName.set(file.name);
      // Create a preview URL
      this.blobUrl = URL.createObjectURL(file);

      // Emit the file to the parent
      this.fileChange.emit(file);

      // Emit the preview URL
      this.onPreviewChange.emit(this.blobUrl);
    } else {
      this.fileChange.emit(null);
      this.onPreviewChange.emit(null);
    }

    // Reset the file input value so the same file can be selected again
    if (target.files) {
      target.value = '';
    }
  }

  onFileDropped(event: any): void {
    event.preventDefault();
    const files = event.dataTransfer!.files;
    const file = files[0];
    this.fileName.set(file?.name!);

    // Simple validation
    if (file && this.fileType.includes('image')) {
      // Create a preview URL
      this.blobUrl = URL.createObjectURL(file);
      this.fileChange.emit(file);
      this.onPreviewChange.emit(this.blobUrl);
    } else if (file && this.fileType.includes('video')) {
      // Create a preview URL
      this.blobUrl = URL.createObjectURL(file);
      this.fileChange.emit(file);
      this.onPreviewChange.emit(this.blobUrl);
    } else if (file && !this.fileType.includes('image')) {
      // For non-images, just emit the raw file
      this.blobUrl = null; // No image preview
      this.fileChange.emit(file);
      this.onPreviewChange.emit(null);
    } else if (file && !this.fileType.includes('video')) {
      // For non-images, just emit the raw file
      this.blobUrl = null; // No image preview
      this.fileChange.emit(file);
      this.onPreviewChange.emit(null);
    }
  }

  onRemoveFile(): void {
    this.blobUrl = null;
    this.previewUrl = undefined;
    this.onPreviewChange.emit(null);
    this.fileName.set('');
  }

  // Cleanup: Revoke object URL to prevent memory leaks if component is destroyed or component updates
  ngOnDestroy(): void {
    if (this.blobUrl) {
      URL.revokeObjectURL(this.blobUrl);
    }
  }
}
