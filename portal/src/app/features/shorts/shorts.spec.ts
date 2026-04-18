import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Shorts } from './shorts';

describe('Shorts', () => {
  let component: Shorts;
  let fixture: ComponentFixture<Shorts>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Shorts],
    }).compileComponents();

    fixture = TestBed.createComponent(Shorts);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
