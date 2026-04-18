import { TestBed } from '@angular/core/testing';

import { AuraService } from './aura-service';

describe('AuraService', () => {
  let service: AuraService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AuraService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
