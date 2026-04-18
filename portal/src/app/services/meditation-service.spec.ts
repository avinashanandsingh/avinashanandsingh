import { TestBed } from '@angular/core/testing';

import { MeditationService } from './meditation-service';

describe('ScaredvibeService', () => {
  let service: MeditationService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(MeditationService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
