import mailer from "@sendgrid/mail";

export default {
  send: async (to: string, templateId:string, data: any) => {
    mailer.setApiKey(process.env.SENDGRID_API_KEY as string);

    const msg = {
      to: to,
      from: { name: 'Support', email: process.env.EMAIL_FROM as string },
      templateId: templateId,
      dynamic_template_data: data
    }    
    const result = await mailer.send(msg)
    console.log(result)
    return result;
  },
};
