import { ICourseData } from "./course";

export interface IOptionData {
  id?: string;
  questionid?: string;
  title?: string;
  sort?: number;
}

export interface IQuestionData {
  id?: string;
  courseid?: String
  course?: ICourseData
  type?: String
  title?: string;
  description?: string;
  status?: string;
  options?: IOptionData[];
}
