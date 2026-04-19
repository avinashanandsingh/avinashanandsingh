import { UserRole } from "./enum";

export default interface User {
  id?: string;
  first_name?: string;
  last_name?: string;
  role?: UserRole;
  email?: string;
  password?: string;
  avatar?: string;
  phone?: string;
  verified?: boolean;
  status?: string;
  last_login_at?: Date;
  creator?: User;
  createdat?: Date;
  updater?: User;
  updatedat?: Date;  
}

export interface IUserData {
  first_name?: string;
  last_name?: string;
  avatar?: string;
  role?: UserRole;
  email?: string;
  password?: string;  
  phone?: string;
  profession?: string;
  income?: number;  
  file?: File
}
