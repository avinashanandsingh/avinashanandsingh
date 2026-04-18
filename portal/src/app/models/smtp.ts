export interface ISmtpSetting {
  id?: string;
  host: string;
  port: string;
  secure?: boolean;
  username: string;
  password: string;
  sender_email: string;
  sender_name: string;
}