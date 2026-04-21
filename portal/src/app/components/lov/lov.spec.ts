import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Lov } from './lov';

describe('Lov', () => {
  let component: Lov;
  let fixture: ComponentFixture<Lov>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Lov],
    }).compileComponents();

    fixture = TestBed.createComponent(Lov);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
