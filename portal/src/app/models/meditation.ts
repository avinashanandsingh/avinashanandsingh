import { ICourseData } from "./course-model";

export interface IMeditationData {  
  id?: string;
  courseid: string;
  course: ICourseData;
  title: string;
  thumbnail: string;
  url?: string;
  status?: string;
}