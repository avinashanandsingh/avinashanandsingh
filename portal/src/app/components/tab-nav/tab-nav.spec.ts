import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TabNav } from './tab-nav';

describe('TabNav', () => {
  let component: TabNav;
  let fixture: ComponentFixture<TabNav>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TabNav],
    }).compileComponents();

    fixture = TestBed.createComponent(TabNav);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
