export default interface ISmtpData {
  id?: string;
  host?: string;
  port?: number;
  username?: string;
  password?: string;  
  sender_name?:string;
  sender_email?:string;
}
