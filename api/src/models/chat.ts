export default interface Chat {
  id: string;
  name: string;
  isGroup: boolean;
  userId: string;
  members: string[];  
  lastUpdated: any;
}
