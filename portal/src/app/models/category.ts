import { IFile } from "./file";

export interface ICategoryData {
  id?: string,
  name: string;
  slug: string;
  description: string;
  icon?: string;
  status?: string;
  createdat?: Date;
}

export interface ICategoryForm {
  id?: string,
  name: string;
  slug: string;
  description: string;
  icon?: IFile;  
}
