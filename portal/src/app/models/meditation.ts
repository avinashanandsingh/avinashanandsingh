import { ICourseData } from "./course";

export interface IMeditationData {  
  id?: string;
  courseid: string;
  course: ICourseData;
  title: string;
  thumbnail: string;
  url?: string;
  free: boolean;
  price: number;
  offer: number;
  status?: string;
}