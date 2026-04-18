import { TestBed } from '@angular/core/testing';

import { ScaredvibeService } from './scaredvibe-service';

describe('ScaredvibeService', () => {
  let service: ScaredvibeService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ScaredvibeService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
