import { UserRole } from "./enum";

export default class SignUp {
  public role: UserRole = UserRole.STUDENT;
  public first_name?: string;
  public last_name?: string;
  public email?: string;
  public phone?: string;
  public password?: string;
}
