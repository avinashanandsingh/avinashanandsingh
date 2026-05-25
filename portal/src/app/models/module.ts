import { ICourseData } from './course';
import { ISchdeuleData } from './schedule';

export interface IModuleData {
  id?: string;
  courseid: string;
  course?: ICourseData;
  scheduleid?: string;
  schedule: ISchdeuleData;
  title: string;
  duration: string;
  sort?: number;
  url?: string;
  status?: string;
}
