export interface ITimeslot {
  id: string;
  name: string;
  serviceid: string;
  service: string;
  start_time: string;
  end_time: string;
  status: 'active' | 'inactive' | 'pending';  
  createdat: string;
}

export interface IService {
  id: string;
  name: string;
  price: number;
  offer: number;
  description?: string;
  status: 'active' | 'inactive';
  timeslots: ITimeslot[];
}

export interface ITimeslotFormData {
  id?: string;
  name: string;
  start_time: string;
  end_time: string;
}

export interface ICreateTimeslotPayload {
  name: string;
  service_id: string;
  start_time: string;
  end_time: string;
  status: 'active' | 'inactive' | 'pending';
  display_order?: number;
}

export interface ITimeslotStatusPayload {
  id: string;
  status: 'active' | 'inactive' | 'pending';
}