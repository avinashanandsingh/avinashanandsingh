import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Aura } from './aura';

describe('Aura', () => {
  let component: Aura;
  let fixture: ComponentFixture<Aura>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Aura],
    }).compileComponents();

    fixture = TestBed.createComponent(Aura);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
