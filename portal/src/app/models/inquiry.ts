import { IUser } from "./user";

export interface IInquiryData {
  id?: string;
  subject: string;
  message: string;
  status: string;
  creator: IUser;
  createdat: Date;
  updater: IUser;
  updatedat?: Date;
}
