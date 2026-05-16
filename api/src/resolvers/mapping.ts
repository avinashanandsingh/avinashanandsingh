import country from "./country";
import state from "./state";
import city from "./city";
import user from "./user";
import category from "./category";
import course from "./course";
import question from "./question";
import option from "./option";
import schedule from "./schedule";
import _module from "./module";
import entrollment from "./entrollment";
import Meditation from "./meditation";
import short from "./short";
import resource from "./resource";
import sacredvibe from "./sacredvibe";
import referral from "./referral";
import service from "./service";
import review from "./review";
import inquiry from "./inquiry";
import log from "./log";
import smtp from "./smtp";
import template from "./template";
import page from "./page";
import setting from "./setting";
import branding from "./branding";
import _enum from "./enum";
/* Chat Feature */
import message from "./message";

import { UserRole } from "../models/enum";
import meditation from "./meditation";
import order from "./order";
import appointment from "./appointment";

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
    name: "enums",
    execute: _enum,
    include: false,
    role: UserRole.ANONYMOUS,
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
    name: "deleteUser",
    execute: user.delete,
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
    name: "changePassword",
    execute: user.changePassword,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "verifyEmail",
    execute: user.verifyEmail,
    include: false,
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
    name: "updateProfile",
    execute: user.profile,
    include: true,
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
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "course",
    execute: course.get,
    include: false,
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
    name: "questions",
    execute: question.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "question",
    execute: question.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newQuestion",
    execute: question.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateQuestion",
    execute: question.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteQuestion",
    execute: question.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "options",
    execute: option.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "option",
    execute: option.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newOption",
    execute: option.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateOption",
    execute: option.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteOption",
    execute: option.delete,
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
    name: "changeScheduleStatus",
    execute: schedule.changeStatus,
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
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "review",
    execute: review.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "postReview",
    execute: review.add,
    include: true,
    role: UserRole.ANONYMOUS,
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
    name: "isEnrolled",
    execute: entrollment.enrolled,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "enroll",
    execute: entrollment.add,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "updateEnrollment",
    execute: entrollment.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "changeEnrollmentStatus",
    execute: entrollment.changeStatus,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "meditations",
    execute: meditation.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "meditation",
    execute: meditation.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addMeditation",
    execute: meditation.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateMeditation",
    execute: Meditation.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "changeMeditationStatus",
    execute: Meditation.changeStatus,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteMeditation",
    execute: Meditation.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "shorts",
    execute: short.list,
    include: false,
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
    name: "sacredvibes",
    execute: sacredvibe.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "sacredvibe",
    execute: sacredvibe.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "addSacredvibe",
    execute: sacredvibe.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateSacredvibe",
    execute: sacredvibe.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteSacredvibe",
    execute: sacredvibe.delete,
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
  {
    name: "template",
    execute: template.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "templates",
    execute: template.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newTemplate",
    execute: template.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateTemplate",
    execute: template.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteTemplate",
    execute: template.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "page",
    execute: page.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "pages",
    execute: page.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newPage",
    execute: page.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updatePage",
    execute: page.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deletePage",
    execute: page.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "branding",
    execute: branding.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "brandings",
    execute: branding.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newBranding",
    execute: branding.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateBranding",
    execute: branding.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteBranding",
    execute: branding.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "setting",
    execute: setting.get,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "settings",
    execute: setting.list,
    include: false,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newSetting",
    execute: setting.add,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "updateSetting",
    execute: setting.update,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "deleteSetting",
    execute: setting.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "order",
    execute: order.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "orders",
    execute: order.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "newOrder",
    execute: order.add,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "updateOrder",
    execute: order.update,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "deleteOrder",
    execute: order.delete,
    include: true,
    role: UserRole.ADMINISTRATOR,
  },
  {
    name: "bought",
    execute: order.bought,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "appointment",
    execute: appointment.get,
    include: true,
    role: UserRole.ANONYMOUS,
  },
  {
    name: "appointments",
    execute: appointment.list,
    include: true,
    role: UserRole.ANONYMOUS,
  },
];

export default mapping;
