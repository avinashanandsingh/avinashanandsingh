import { IUser } from './user';

export interface IOrderData {
  id?: string;
  orderid?: string;
  context?: string;
  contextid?: string;
  price?: number;
  order_status: string;
  payment_status: string;
  createdby?: string;
  creator?: IUser;
  createdat?: Date;
  updatedby?: string;
  updater?: IUser;
  updatedat?: Date;
}
