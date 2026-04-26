import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Sacredvibes } from './sacredvibes';

describe('Scarevibes', () => {
  let component: Sacredvibes;
  let fixture: ComponentFixture<Sacredvibes>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Sacredvibes],
    }).compileComponents();

    fixture = TestBed.createComponent(Sacredvibes);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
