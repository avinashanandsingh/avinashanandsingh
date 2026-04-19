import { Status, UserRole } from './enum';

export interface IUser {
  id?: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  role: UserRole;
  status: Status;
  avatar?: string;
  verified?: boolean;
  createdat: Date;
  profession?: string;
  currency?: string;
  income?: number;
  referrerid?: string;
  last_login_at?: string;
}

export interface IUserFormData {
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  role?: UserRole;
}

export interface IChangeUserStatus {
  status: Status;
  notes: string;
}
