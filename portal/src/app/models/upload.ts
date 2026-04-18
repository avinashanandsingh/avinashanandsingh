interface IUploadedFile {
  id: string;
  file: File;
  fileName: string;
  fileSize: number;
  fileType: string;
  content?: string;
  previewUrl?: string;
  uploadProgress: number;
  status: 'pending' | 'uploading' | 'success' | 'error';
  errorMessage?: string;
}
