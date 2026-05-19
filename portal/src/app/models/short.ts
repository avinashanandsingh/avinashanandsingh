export interface IShortData {
  id?: string;
  title: string;
  description?: string;
  url?: string;
  status?:string;
  sort?:number;
  likes?: number;
  hits?: number;
  createdat: Date;
}
