import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Pager } from './pager';

describe('Pager', () => {
  let component: Pager;
  let fixture: ComponentFixture<Pager>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Pager]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Pager);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
