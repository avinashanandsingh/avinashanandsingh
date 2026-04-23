import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { ReferralService } from '../../services/referral-service';
import Filter from '../../models/filter';
import { IReferralData } from '../../models/referral';
import { CommonModule } from '@angular/common';
import { Loader } from '../../components/loader/loader';
import { TitleService } from '../../services/title-service';

@Component({
  selector: 'app-referral',
  imports: [CommonModule, Loader],
  templateUrl: './referral.html',
  styleUrl: './referral.css',
})
export class Referral implements OnInit {
  rowCount = signal<number>(1);
  list = signal<IReferralData[]>([]);
  loaderDialog = signal<boolean>(false);
  constructor(
    private service: ReferralService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Referrals';
    this.show();
    await this.load({});    
    this.hide();
  }
  async load(filter: Filter): Promise<void> {
    let result = await this.service.list(filter);
    if (result) {
      this.rowCount.set(result.count!);
      this.list.set(result.rows!);
    }
  }

  async show() {
    this.loaderDialog.set(true);
  }
  hide() {
    this.loaderDialog.set(false);
  }
  async delete(id: string): Promise<void> {
    this.show();
    let result = await this.service.delete(id);
    this.load({});
    this.hide();
  }
}
