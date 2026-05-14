import { IUser } from "./user";

export interface IAppointmentData {
  id?: string;
  orderid?: string;
  machine?: string;
  slot?: string;
  start_time?: string;
  end_time?: string;
  createdat?: Date;
  creator?: IUser;
  status?: string;
}