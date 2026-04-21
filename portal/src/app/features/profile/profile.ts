import { Component, inject, OnInit, signal } from '@angular/core';
import { StorageService } from '../../services/storage-service';
import { IUser } from '../../models/user';
import { jwtDecode } from 'jwt-decode';
import { UserService } from '../../services/user-service';
import { CommonModule } from '@angular/common';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Loader } from '../../components/loader/loader';
import Swal from 'sweetalert2';
import { TitleService } from '../../services/title-service';
import { CommonService } from '../../services/common-service';
import { COP, LOP } from '../../models/enum';
import { Lov } from '../../components/lov/lov';
import { IListItem } from '../../models/lov';
import Criteria from '../../models/criteria';

@Component({
  selector: 'app-profile',
  imports: [CommonModule, ReactiveFormsModule, Loader, Lov],
  templateUrl: './profile.html',
  styleUrl: './profile.css',
})
export class Profile implements OnInit {
  user = signal<IUser | null>(null);
  loader = signal<boolean>(false);
  country_list = signal<IListItem[]>([]);
  country_id = signal<number | undefined>(undefined);
  state_list = signal<IListItem[]>([]);
  stateId = signal<number>(0);
  city_list = signal<IListItem[]>([]);
  cityId = signal<number>(0);
  file = signal<File | null>(null);
  blobUrl = signal<string | null>(null);
  form: FormGroup = new FormGroup({
    id: new FormControl(''),
    role: new FormControl(''),
    first_name: new FormControl('', [Validators.required]),
    last_name: new FormControl('', [Validators.required]),
    email: new FormControl('', [Validators.required]),
    phone: new FormControl('', [Validators.required, Validators.pattern('^\\+[1-9]\\d{10,14}$')]),
    countryid: new FormControl(''),
    stateid: new FormControl(''),
    cityid: new FormControl(''),
    profession: new FormControl(''),
    income: new FormControl('', [Validators.pattern(/^\d+(\.\d{1,2})?$/)]),
  });
  constructor(
    private store: StorageService,
    private service: UserService,
    private common: CommonService,
    private titleService: TitleService,
  ) {}
  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Profile';
    await this.refresh();
  }
  async refresh() {
    const token = this.store.get('xt');
    if (token) {
      this.loader.set(true);
      let decoded: any = jwtDecode(token);
      let result = await this.service.get(decoded?.id);
      let userData = result?.data?.user;
      this.user.set(result?.data?.user!);
      this.form.patchValue(userData!);
      this.load_country(userData?.countryid!);
     

      await this.load_state(userData.countryid!);
      this.stateId.set(userData?.stateid!);

      await this.load_city(userData.countryid!, userData.stateid!);
      this.cityId.set(userData?.cityid!);
      
      this.loader.set(false);
    }
  }
  async load_country(countryId?:number): Promise<void> {
    let result = await this.common.country_list({});
    let nlst: IListItem[] = result?.rows!.map((item) => {
      return {
        id: item.id!,
        label: item.name!,
        value: item.name!,
      } as IListItem;
    });
    this.country_list.set(nlst);
     this.country_id.set(countryId);
  }
  async load_state(countryId?: number | string) {
    if (countryId) {
      let result = await this.common.state_list({
        criteria: [{ column: 'countryid', cop: COP.eq, value: Number(countryId!) }],
      });
      let nlst: IListItem[] = result?.rows!.map((item) => {
        return {
          id: item.id!,
          label: item.name!,
          value: item.name!,
        } as IListItem;
      });
      this.state_list.set(nlst);
    }
  }
  async load_city(countryId?: number | string, stateId?: number | string) {
    let criteria: Criteria[] = [];
    if (countryId) {
      criteria.push({ column: 'countryid', cop: COP.eq, value: countryId! });
    }
    if (stateId) {
      criteria.push({ column: 'stateid', cop: COP.eq, lop: LOP.AND, value: stateId! });
    }
    let result = await this.common.city_list({
      criteria: criteria,
    });
    let nlst: IListItem[] = result?.rows!.map((item) => {
      return {
        id: item.id!,
        label: item.name!,
        value: item.name!,
      } as IListItem;
    });
    this.city_list.set(nlst);
  }

  async countryHandler(item?: IListItem): Promise<void> {
    this.form.controls['countryid'].setValue(item?.id);
    if (item) {
      this.loader.set(true);
      await this.load_state(item?.id);
      this.loader.set(false);
    }
  }

  async stateHandler(item?: IListItem): Promise<void> {
    this.form.controls['stateid'].setValue(item?.id);
    let cid = this.country_id();
    let sid = item?.id;
    if (item) {
      this.loader.set(true);
      await this.load_city(cid, sid);
      this.loader.set(false);
    }
  }

  async cityHandler(item?: IListItem): Promise<void> {
    this.form.controls['cityid'].setValue(item?.id);    
  }

  select($event: Event) {
    const target = $event.target as HTMLInputElement;
    if (target.files && target.files.length > 0) {
      const file = target.files[0];
      this.blobUrl.set(URL.createObjectURL(file));
      this.file.set(file);
    }
  }
  async save(): Promise<void> {
    if (this.form.invalid) return;
    let formData = this.form.getRawValue();

    var fd = new FormData();
    let input: any = {
      ...formData,
      file: null,
    };
    delete input.id;
    input.income = Number(input.income);
    let body = {
      query:
        'mutation update ($id: UUID!, $input: UserIn!) { updateUser(id:$id, input: $input) { id } }',
      variables: {
        id: formData.id,
        input: {
          ...input,
        },
      },
    };

    fd.append('operations', JSON.stringify(body));
    fd.append('map', JSON.stringify({ '0': ['variables.input.file'] }));

    if (this.file()) {
      fd.append('0', this.file()!, this.file()!.name);
    } else {
      fd.append('0', '');
    }
    let result: any;
    this.loader.set(true);
    if (formData.id) {
      result = await this.service.saveFormData(fd);
      if (result?.errors) {
        let error = result?.errors?.shift();
        let msg = error?.extensions?.originalError?.message;
        Swal.fire({
          title: 'Failed',
          html: msg,
          icon: 'error',
          timer: 3000,
        });
      } else {
        Swal.fire({
          title: 'Success',
          html: 'User updated successfully',
          icon: 'success',
          timer: 3000,
        });
      }
    }
    await this.refresh();
    this.loader.set(false);
  }
}
