import User from "./user";

export default interface IReferralData {
  id?: string;
  first_name?: string;
  last_name?: string;
  email?: string;
  referrer: string;
  status?: string;
  referby?: User;
  referredat?: Date;
  acceptedat?: Date;
}
