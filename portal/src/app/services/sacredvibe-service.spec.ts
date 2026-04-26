import { TestBed } from '@angular/core/testing';

import { SacredvibeService } from './sacredvibe-service';

describe('ScaredvibeService', () => {
  let service: SacredvibeService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SacredvibeService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
