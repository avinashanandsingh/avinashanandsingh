import { IUser } from "./user";

export interface ITemplateData {
  id?: string;
  type: string;
  category: string;
  subject?: string;
  body?:string;
  creator?: IUser;
  createdat?: Date;
  updater?: IUser;
  updatedat?: Date;
}