import { Component, OnInit, signal } from '@angular/core';
import { EnrollmentService } from '../../../services/enrollment-service';
import Filter from '../../../models/filter';
import { IEnrollmentData } from '../../../models/enrollment';

@Component({
  selector: 'enrollment-list',
  imports: [],
  templateUrl: './list.html',
  styleUrl: './list.css',
})
export default class List implements OnInit {
  list = signal<IEnrollmentData[]>([]);
  constructor(private service:EnrollmentService){

  }
  async ngOnInit(): Promise<void> {
    await this.load({});
  }

  async load(filter: Filter):Promise<void>{
    let result = await this.service.list(filter);
    if(result){
      this.list.set(result?.rows!);
    }
  }
}
