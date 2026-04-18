import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Smtp } from './smtp';

describe('Smtp', () => {
  let component: Smtp;
  let fixture: ComponentFixture<Smtp>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Smtp],
    }).compileComponents();

    fixture = TestBed.createComponent(Smtp);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
