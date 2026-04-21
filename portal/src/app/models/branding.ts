import { IUser } from "./user";

export interface IBrandingData {
  id?: string;
  type: string;
  title: string;
  url?: string;
  content?:string;
  creator?: IUser;
  createdat?: Date;
  updater?: IUser;
  updatedat?: Date;
}