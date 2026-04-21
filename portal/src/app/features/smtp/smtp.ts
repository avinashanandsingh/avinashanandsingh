import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { SmtpService } from '../../services/smtp-service';
import { CommonModule } from '@angular/common';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Loader } from '../../components/loader/loader';
import { Dialog } from '../../components/dialog/dialog';
import { TitleService } from '../../services/title-service';

@Component({
  selector: 'app-smtp',
  imports: [CommonModule, ReactiveFormsModule, Loader, Dialog],
  templateUrl: './smtp.html',
  styleUrl: './smtp.css',
})
export class Smtp implements OnInit {
  saving = signal<boolean>(false);
  error = signal<string | null>(null);
  showPassword = signal<boolean>(false);
  loaderDialog = signal<boolean>(false);
  confirmDialog = signal<boolean>(false);
  dialogButtons = signal<Array<{ label: string; action: any; type: any }>>([
    {
      label: 'Cancel',
      action: () => {
        this.hide(this.confirmDialog);
      },
      type: 'btn btn-secondary',
    },
    {
      label: 'Confirm',
      action: async () => {
        this.hide(this.confirmDialog);
        this.show(this.loaderDialog);
        let data = this.form.getRawValue();
        let result = await this.service.save({ ...data });
        if (result?.data?.updateSmtp?.id) {
          await this.load();
          this.hide(this.loaderDialog);
        }
      },
      type: 'btn btn-primary',
    },
  ]);

  form: FormGroup = new FormGroup({
    id: new FormControl(''),
    host: new FormControl('', [Validators.required]),
    port: new FormControl('', [Validators.required]),
    username: new FormControl('', [Validators.required, Validators.email]),
    password: new FormControl('', [Validators.required]),
    sender_name: new FormControl('', [Validators.required]),
    sender_email: new FormControl('', [Validators.required, Validators.email]),
  });

  constructor(
    private service: SmtpService,
    private titleService: TitleService,
  ) {}

  async ngOnInit(): Promise<void> {
    this.titleService.title = 'Smtp Settings';
    this.loaderDialog.set(true);
    this.load();
    this.loaderDialog.set(false);
  }
  async load() {
    let result = await this.service.get();
    if (result?.data?.smtp) {
      this.form.patchValue(result.data.smtp);
      //this.settings.set(result.data.smtp);
      this.error.set(null);
    } else {
      this.error.set('Unable to load settings');
    }
  }
  async save() {
    if (this.form.valid) {
      this.show(this.confirmDialog);
    }
  }

  show(me: WritableSignal<boolean>) {
    me.set(true);
  }
  hide(me: WritableSignal<boolean>) {
    me.set(false);
  }
}
