import { Component, OnInit, signal } from '@angular/core';
import { EnrollmentService } from '../../../services/enrollment-service';
import Filter from '../../../models/filter';
import { IEnrollmentData } from '../../../models/enrollment';
import { TitleService } from '../../../services/title-service';

@Component({
  selector: 'enrollment-list',
  imports: [],
  templateUrl: './list.html',
  styleUrl: './list.css',
})
export default class List implements OnInit {
  list = signal<IEnrollmentData[]>([]);
  constructor(
    private service: EnrollmentService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title ="Enrollments"
    await this.load({});
  }

  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    if (result) {
      this.list.set(result?.rows!);
    }
  }
}
