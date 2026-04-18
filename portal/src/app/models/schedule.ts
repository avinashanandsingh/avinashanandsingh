import { ICourseData } from "./course-model";

export interface ISchdeuleData {
  id?: string;
  courseid: string;
  course?:ICourseData;
  title: string;
  start_date: Date;
  end_date: Date;
  start_time: string;
  end_time: string;
  deadline: Date;
  capacity: number;
  enrollment_count?: number;
  status?: string;
}
