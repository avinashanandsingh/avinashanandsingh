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
import course from "./course";
import progress from "./progress";
import _module from "./module";

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
  course,
  progress,
  module: _module,
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
  generatePassword: (length: number) => {
    const LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
    const UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const NUMBERS = "0123456789";
    // A good set of common special characters
    const SPECIAL = "!@#$%^&*()_+[]{}|;:,.<>?";

    // The full pool of characters to draw filler characters from
    const FULL_POOL = LOWERCASE + UPPERCASE + NUMBERS + SPECIAL;

    // --- Input Validation ---
    if (typeof length !== "number" || length < 4) {
      throw new Error(
        "Password length must be at least 4 to guarantee all required character types.",
      );
    }

    // Array to hold the characters of the password
    let passwordChars = [];

    // Helper function to get a random character from a pool
    const getRandomChar = (pool:any) => {
      const randomIndex = Math.floor(Math.random() * pool.length);
      return pool[randomIndex];
    };

    // --- Step 1: Guarantee the minimum requirements (The Constraints) ---
    // By pushing these first, we guarantee their inclusion.
    passwordChars.push(getRandomChar(LOWERCASE));
    passwordChars.push(getRandomChar(UPPERCASE));
    passwordChars.push(getRandomChar(NUMBERS));
    passwordChars.push(getRandomChar(SPECIAL));

    // --- Step 2: Fill the remaining slots (The Random Filler) ---
    const remainingLength = length - 4;

    for (let i = 0; i < remainingLength; i++) {
      passwordChars.push(getRandomChar(FULL_POOL));
    }

    // --- Step 3: Shuffle the array (CRITICAL STEP) ---
    // If we didn't shuffle, the password would always start with the
    // guaranteed characters (e.g., [lower, upper, number, special]...)
    // We use the Fisher-Yates algorithm for proper shuffling.
    for (let i = passwordChars.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [passwordChars[i], passwordChars[j]] = [
        passwordChars[j],
        passwordChars[i],
      ];
    }

    // --- Step 4: Return the password string ---
    return passwordChars.join("");
  },
};
