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
import email from "./email";
import s3 from "./s3";
import video from "./video";
export default {
  otp: otp,
  email: email,
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
