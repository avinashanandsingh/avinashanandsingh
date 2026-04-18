import { IUser } from './user';

export interface IReferralData {
  id?: string;
  referrer: string;
  referredat: Date;
  referby: IUser;
  first_name: string;
  last_name: string;
  email: string;
  acceptedat: Date;
}
