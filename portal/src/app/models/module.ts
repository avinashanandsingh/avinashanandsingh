import { ICourseData } from './course-model';
import { ISchdeuleData } from './schedule';

export interface IModuleData {
  id?: string;
  courseid: string;
  course?: ICourseData;
  scheduleid?: string;
  schedule: ISchdeuleData;
  title: string;
  description: string;
  sort?: number;
  url?: string;
  status?: string;
  completed?: boolean;
  completedat?: Date;
}
