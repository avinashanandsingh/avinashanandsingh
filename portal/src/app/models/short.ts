export interface IShortData {
  id?: string;
  title: string;
  thumbnail: string;
  url?: string;
  status?:string;
  sort?:number;
  likes?: number;
  hits?: number;
  createdat: Date;
}
