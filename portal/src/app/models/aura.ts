export interface ITimeslotData {
  id?: string;
  serviceid?: string;
  name: string;
  start_time: string;
  end_time: string;
}

export interface IAuraData {
  id?: string;
  name: string;
  price: number;
  offer: number;
  status: string;
  timeslots?: ITimeslotData[];
}
