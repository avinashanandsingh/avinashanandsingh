import helper from "../../helper/index";
export default async (
  _: any,
  args: {
    otp: string;
  },
): Promise<any> => {
  let otp: any = await helper.otp.verify(args.otp);
  console.log("reset.otp.row: ", otp);
  if (otp) {
    let user = otp.user;
    console.log("verifyEmail.user: ", user);
    let state = await helper.user.update(user.id, {
      status: "ACTIVE",
      verified: true,
    });
    if (state) {
      await helper.otp.delete(args.otp);
      return {
        succeed: true,
        message: "Your account is verified, now you can sign in.",
      };
    } else {
      return {
        succeed: false,
        message: "Unable to verify your account.",
      };
    }
  } else {
    return { succeed: false, message: "Invalid OTP" };
  }
};
