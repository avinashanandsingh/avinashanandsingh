import { Routes } from '@angular/router';
import { SignIn } from './components/sign-in/sign-in';
import { SignUp } from './components/sign-up/sign-up';
import { ResetPassword } from './components/reset-password/reset-password';
import { MainLayout } from './layouts/main/main';
import { IdentityService } from './services/identity-service';
import { Dashboard } from './components/dashboard/dashboard';
import CourseList from './features/courses/list/list';
//import { CoursePlayer } from './core/components/course-player/course-player';
import EnrollmentList from './features/enrollment/list/list';
import { Profile } from './features/profile/profile';
import { GuestLayout } from './layouts/guest/guest';
import { UserRole } from './models/enum';
import { Unauthorized } from './components/unauthorized/unauthorized';
import { ForgotPassword } from './components/forgot-password/forgot-password';
import { Privacy } from './features/privacy/privacy';
import { Terms } from './features/terms/terms';
import { Support } from './features/support/support';
import { Category } from './features/category/category';
import { Shorts } from './features/shorts/shorts';
import ManageUser from './features/user/manage/manage';
import ResourceList from './features/resource/list/list';
import { MyCourseList } from './features/courses/my-course-list/my-course-list';
//import { Landing } from './features/landing/landing';
import { Scarevibes } from './features/scarevibes/scarevibes';
import { Meditation } from './features/meditation/meditation';
import { Aura } from './features/aura/aura';
import MarketingList from './features/marketing/list/list';
import { Smtp } from './features/smtp/smtp';
import { Unavailable } from './features/unavailable/unavailable';
import { Landing } from './features/landing/landing';
import { Schedule } from './features/schedule/schedule';
import { Module } from './features/module/module';
import { Referral } from './features/referral/referral';
import { Orders } from './features/orders/orders';
import { Inquiry } from './features/inquiry/inquiry';
import { Template } from './features/template/template';
import { Page } from './features/page/page';

export const routes: Routes = [
  {
    path: '',
    component: MainLayout,
    children: [
      { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
      {
        path: 'dashboard',
        component: Dashboard,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR, UserRole.STUDENT] },
      },
      { path: 'category', component: Category, data: { roles: [UserRole.ADMINISTRATOR] } },
      {
        path: 'courses',
        component: CourseList,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'schedules',
        component: Schedule,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'modules',
        component: Module,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'my-courses',
        component: MyCourseList,
        canActivate: [IdentityService],
        data: { roles: [UserRole.STUDENT] },
      },
      //{ path: 'courses/:id', component: CoursePlayer },
      {
        path: 'enrollments',
        component: EnrollmentList,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'shorts',
        component: Shorts,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'resources',
        component: ResourceList,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'meditations',
        component: Meditation,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'scare-vibes',
        component: Scarevibes,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'services',
        component: Aura,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'marketing',
        component: MarketingList,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'referrals',
        component: Referral,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'orders',
        component: Orders,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'inquiries',
        component: Inquiry,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'smtp',
        component: Smtp,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'templates',
        component: Template,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'pages',
        component: Page,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'users',
        component: ManageUser,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR] },
      },
      {
        path: 'profile',
        component: Profile,
        canActivate: [IdentityService],
        data: { roles: [UserRole.ADMINISTRATOR, UserRole.STUDENT] },
      },
    ],
  },
  { path: '', redirectTo: '/', pathMatch: 'full' },
  {
    path: '',
    component: GuestLayout,
    children: [
      { path: '', component: Landing },
      { path: 'signin', component: SignIn },
      { path: 'signup', component: SignUp },
      { path: 'forgot', component: ForgotPassword },
      { path: 'reset', component: ResetPassword },
      { path: 'privacy', component: Privacy },
      { path: 'terms', component: Terms },
      { path: 'support', component: Support },
    ],
  },
  { path: 'unauthorized', component: Unauthorized },
  { path: 'unavailable', component: Unavailable },
  /* {
    path: '**',
    redirectTo: '/courses',
  }, */
];
