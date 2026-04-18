import { Component, OnInit, signal } from '@angular/core';
import { Loader } from "../../components/loader/loader";
import { InquiryService } from '../../services/inquiry-service';
import { CommonModule } from '@angular/common';
import { IInquiryData } from '../../models/inquiry';
import Filter from '../../models/filter';

@Component({
  selector: 'app-inquiry',
  imports: [CommonModule, Loader],
  templateUrl: './inquiry.html',
  styleUrl: './inquiry.css',
})
export class Inquiry implements OnInit {
  list = signal<IInquiryData[]>([]);
  loaderDialog = signal<boolean>(false);
  constructor(private service: InquiryService){

  }
  async ngOnInit(): Promise<void> {
    await this.load({});
  }
  async load(filter:Filter){
    let result = await this.service.list(filter);
    if(result){
      this.list.set(result.rows!);
    }
  }
}
