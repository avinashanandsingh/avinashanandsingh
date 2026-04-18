import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Unavailable } from './unavailable';

describe('Unavailable', () => {
  let component: Unavailable;
  let fixture: ComponentFixture<Unavailable>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Unavailable],
    }).compileComponents();

    fixture = TestBed.createComponent(Unavailable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
