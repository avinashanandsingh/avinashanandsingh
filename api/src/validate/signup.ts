import Result from "./result";
import User from "../models/user";
export default async (args: User): Promise<Result> => {
  let result = new Result();
  if (args.first_name!.trim().length <= 0) {
    result.code = 1234;
    result.success = false;
    result.message = "first name should not be empty";
    return result;
  }

  if (args.last_name!.trim().length <= 0) {
    result.code = 1234;
    result.success = false;
    result.message = "last name should not be empty";
  }

  if (args.email!.trim().length <= 0) {
    result.code = 1234;
    result.success = false;
    result.message = "email should not be empty";
  }  

  if (args.phone!.trim().length <= 0) {
    result.code = 1234;
    result.success = false;
    result.message = "phone should not be empty";
  }

  if (args.password!.trim().length <= 0) {
    result.code = 1234;
    result.success = false;
    result.message = "password should not be empty";
  }
  return result;
};
