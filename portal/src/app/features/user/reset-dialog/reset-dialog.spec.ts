import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ResetDialog } from './reset-dialog';

describe('ResetDialog', () => {
  let component: ResetDialog;
  let fixture: ComponentFixture<ResetDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ResetDialog],
    }).compileComponents();

    fixture = TestBed.createComponent(ResetDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
