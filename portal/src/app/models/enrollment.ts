import { ICourseData } from './course-model';
import { ISchdeuleData } from './schedule';
import { IUser } from './user';

export interface IEnrollmentData {
  id?: string;
  userid?: string;
  courseid: string;
  course: ICourseData;
  scheduleid?: string;
  schedule?: ISchdeuleData;
  status?: string;
  enrolledat: Date;
  completedat?: Date;
  certificate_issued_at?: Date;
  droppedat?: Date;
  droppedby?: IUser;
  notes?: string;
}
