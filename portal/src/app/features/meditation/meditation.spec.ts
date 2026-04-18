import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Meditation } from './meditation';

describe('Meditation', () => {
  let component: Meditation;
  let fixture: ComponentFixture<Meditation>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Meditation],
    }).compileComponents();

    fixture = TestBed.createComponent(Meditation);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
