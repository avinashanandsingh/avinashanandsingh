export default interface Message {
  id?: number;
  code?: number;
  type?: string;
  language?: string;
  message?: string;
  creator?: string;
  createdat?: Date;
  updater?: string;
  updatedat?: Date;
}
