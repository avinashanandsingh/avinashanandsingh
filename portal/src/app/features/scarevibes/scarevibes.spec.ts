import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Scarevibes } from './scarevibes';

describe('Scarevibes', () => {
  let component: Scarevibes;
  let fixture: ComponentFixture<Scarevibes>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Scarevibes],
    }).compileComponents();

    fixture = TestBed.createComponent(Scarevibes);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
