import { ICourseData } from './course';
import { ISchdeuleData } from './schedule';
import { IUser } from './user';

export interface IEnrollmentData {
  id?: string;
  userid?: string;
  user?: IUser;
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
