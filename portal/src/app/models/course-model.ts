import { CourseStatus } from "./enum";

export interface ICourseModuleContent {
  type: 'video' | 'audio' | 'text' | 'pdf' | 'url';
  value: string; // URL, content, or file path
  description?: string;
}

export interface ICourseData {
  id?: string;
  categoryid?: string;
  category?: any;
  title: string;
  description: string;
  thumbnail?: string;
  url?: string;
  short: boolean;
  level: string;
  free: boolean;
  price?: number;
  offer?: number;
  status?: CourseStatus;
}

export const COURSE_ACTIONS = ['edit', 'publish', 'archive'];
