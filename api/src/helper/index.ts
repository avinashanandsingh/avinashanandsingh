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
import template from "./template";
import referral from "./referral";
import smtp from "./smtp";
import timeslot from "./timeslot";
import schedule from "./schedule";
import reaction from "./reaction";
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
  referral: referral,
  timeslot,
  schedule,
  reaction,
  toMoney(num: number) {
    return Math.round(num * 100) / 100;
  },
  toRound(num: number) {
    return Math.round(num);
  },
  
  orderId: (date: any) => {
    let id: any[] = [];
    let time = date.getTime().toString();
    let part1 = time.slice(0, 4);
    let part2 = time.slice(4, 8);
    let part3 = time.slice(8);

    id.push(part1);
    id.push(part2);
    id.push(part3);
    return id.join("-");
  },
};
