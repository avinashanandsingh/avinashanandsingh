import method from "./method";
import data from "./data/index";
import date from "./date";
import user from "./user";
import chat from "./chat";
import message from "./message";
import cache from "./cache";
import geo from "./geo";
import log from "./log";
import otp from "./otp";
import s3 from "./s3";
import video from "./video";
import send from "./send";
import _enum from "./enum";
import template from "./template"
import smtp from "./smtp"
export default {
  enum: _enum,
  otp: otp,
  smtp,
  template,
  send: send,
  geo: geo,
  cache: cache,
  data: data,
  date: date,
  get: {
    method: method,
  },
  log: log,
  user: user,
  chat: chat,
  message: message,
  s3: s3,
  video: video,
};
