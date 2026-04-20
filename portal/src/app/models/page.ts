import { IUser } from "./user";

export interface IPageData {
  id?: string;
  type: string;
  title: string;  
  body?:string;
  creator?: IUser;
  createdat?: Date;
  updater?: IUser;
  updatedat?: Date;
}