import nodemailer from "nodemailer";
import ITemplateData from "../../models/template";
import helper from "..";

export default async (to: { address: string, name: string }, template: ITemplateData) => {
  let smtp = await helper.smtp.get();
  let transporter = nodemailer.createTransport({
    host: smtp?.host,
    auth: {
      user: smtp?.username,
      pass: smtp?.password, // the app password you generated, paste without spaces
    },
    secure: true,
    port: smtp?.port,
  });
  let result = await transporter.sendMail({
    from: { address: smtp?.sender_email!, name: smtp?.sender_name! }, // your email
    to: { address: to.address, name: to.name }, // the email address you want to send an email to
    subject: template.subject!, // The title or subject of the email
    html: template.body!, // I like sending my email as html, you can send \
    // emails as html or as plain text    
  });
  //console.log(result);
  return result;
};
