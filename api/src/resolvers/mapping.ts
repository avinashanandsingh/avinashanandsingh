import country from "./country";
import state from "./state";
import city from "./city";
import user from "./user";
import category from "./category";
import course from "./course";
import schedule from "./schedule";
import _module from "./module";
import entrollment from "./entrollment";
import short from "./short";
import resource from "./resource";
import scaredvibe from "./scaredvibe";
import referral from "./referral";
import service from "./service";
import review from "./review";
import inquiry from "./inquiry";
import log from "./log";
import smtp from "./smtp";

/* Chat Feature */
import message from "./message";

import { UserRole } from "../models/enum";

const mapping = [
  {
    name: "countries",
    execute: country.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "country",
    execute: country.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "states",
    execute: state.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "state",
    execute: state.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "cities",
    execute: city.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "city",
    execute: city.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "log",
    execute: log.get,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "logs",
    execute: log.list,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "addUser",
    execute: user.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "changeUserStatus",
    execute: user.changeStatus,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateUser",
    execute: user.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "user",
    execute: user.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "users",
    execute: user.list,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "signin",
    execute: user.signin,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "exist",
    execute: user.exist,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "signout",
    execute: user.signout,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "forgot",
    execute: user.forgot,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "reset",
    execute: user.reset,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "changePassword",
    execute: user.changePassword,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "verify",
    execute: user.verify,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "signup",
    execute: user.signup,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "message",
    execute: message.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "messages",
    execute: message.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newMessage",
    execute: message.add,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "updateMessage",
    execute: message.update,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "categories",
    execute: category.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "category",
    execute: category.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addCategory",
    execute: category.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateCategory",
    execute: category.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteCategory",
    execute: category.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "courses",
    execute: course.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "course",
    execute: course.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addCourse",
    execute: course.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateCourse",
    execute: course.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "publishCourse",
    execute: course.publish,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "archiveCourse",
    execute: course.archive,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "schedules",
    execute: schedule.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "schedule",
    execute: schedule.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addSchedule",
    execute: schedule.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateSchedule",
    execute: schedule.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteSchedule",
    execute: schedule.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "reviews",
    execute: review.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "review",
    execute: review.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "postReview",
    execute: review.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteReview",
    execute: review.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "modules",
    execute: _module.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "module",
    execute: _module.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addModule",
    execute: _module.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateModule",
    execute: _module.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteModule",
    execute: _module.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "services",
    execute: service.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "service",
    execute: service.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addService",
    execute: service.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateService",
    execute: service.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteService",
    execute: service.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "enrollments",
    execute: entrollment.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "enrollment",
    execute: entrollment.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "enroll",
    execute: entrollment.add,
    include: true,
    role: UserRole.STUDENT,
  },
  {
    name: "updateEnrollment",
    execute: entrollment.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "shorts",
    execute: short.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "short",
    execute: short.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addShort",
    execute: short.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateShort",
    execute: short.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteShort",
    execute: short.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "resources",
    execute: resource.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "resource",
    execute: resource.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addResource",
    execute: resource.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateResource",
    execute: resource.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteResource",
    execute: resource.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "scaredvibes",
    execute: scaredvibe.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "scaredvibe",
    execute: scaredvibe.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addScaredvibe",
    execute: scaredvibe.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateScaredvibe",
    execute: scaredvibe.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteScaredvibe",
    execute: scaredvibe.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
   {
    name: "referrals",
    execute: referral.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "referral",
    execute: referral.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "refer",
    execute: referral.refer,
    include: true,
    role: UserRole.ADMINISTRATOR,
  }, 
  {
    name: "deleteReferral",
    execute: referral.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "inquiries",
    execute: inquiry.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "inquiry",
    execute: inquiry.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newInquiry",
    execute: inquiry.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateInquiry",
    execute: inquiry.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteInquiry",
    execute: inquiry.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "smtp",
    execute: smtp.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addSmtp",
    execute: smtp.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateSmtp",
    execute: smtp.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
];

export default mapping;
