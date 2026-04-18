// timeslot.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of, BehaviorSubject } from 'rxjs';
import {
  ITimeslot,
  ITimeslotFormData,
  ICreateTimeslotPayload,
  ITimeslotStatusPayload,
  IService,
} from '../models/timeslot';
import { catchError, tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class TimeslotService {
  private apiUrl = '/api/timeslots';
  private servicesApiUrl = '/api/services';

  private timeslotsSubject = new BehaviorSubject<ITimeslot[]>([]);
  public timeslots$ = this.timeslotsSubject.asObservable();

  private servicesSubject = new BehaviorSubject<IService[]>([]);
  public services$ = this.servicesSubject.asObservable();

  constructor(private http: HttpClient) {}

  // Get all services with timeslots
  getServices(): Observable<IService[]> {
    return this.http.get<IService[]>(this.servicesApiUrl).pipe(
      tap((services) => this.servicesSubject.next(services)),
      catchError(this.handleError<IService[]>('getServices')),
    );
  }

  // Get all timeslots
  getTimeslots(): Observable<ITimeslot[]> {
    return this.http.get<ITimeslot[]>(this.apiUrl).pipe(
      tap((timeslots) => this.timeslotsSubject.next(timeslots)),
      catchError(this.handleError<ITimeslot[]>('getTimeslots')),
    );
  }

  // Create new timeslot
  createTimeslot(payload: ITimeslotFormData): Observable<ITimeslot> {
    return this.http.post<ITimeslot>(this.apiUrl, payload).pipe(
      tap((timeslot) => this.timeslotsSubject.next(this.timeslotsSubject.value)),
      catchError(this.handleError<ITimeslot>('createTimeslot')),
    );
  }

  // Update timeslot
  updateTimeslot(id: string, payload: ITimeslotFormData): Observable<ITimeslot> {
    const data: any = {
      name: payload.name,
      start_time: payload.start_time,
      end_time: payload.end_time      
    };

    return this.http.patch<ITimeslot>(`${this.apiUrl}/${id}`, data).pipe(
      tap((timeslot) => this.timeslotsSubject.next(this.timeslotsSubject.value)),
      catchError(this.handleError<ITimeslot>('updateTimeslot')),
    );
  }

  // Delete timeslot
  deleteTimeslot(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`).pipe(
      tap(() => this.timeslotsSubject.next(this.timeslotsSubject.value)),
      catchError(this.handleError<void>('deleteTimeslot')),
    );
  }

  // Change status
  changeStatus(payload: ITimeslotStatusPayload): Observable<ITimeslot> {
    return this.http
      .patch<ITimeslot>(`${this.apiUrl}/${payload.id}/status`, { status: payload.status })
      .pipe(
        tap((timeslot) => this.timeslotsSubject.next(this.timeslotsSubject.value)),
        catchError(this.handleError<ITimeslot>('changeStatus')),
      );
  }

  // Get service with timeslots by ID
  getServiceById(id: string): Observable<IService> {
    return this.http
      .get<IService>(`${this.servicesApiUrl}/${id}`)
      .pipe(catchError(this.handleError<IService>('getServiceById')));
  }

  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      console.error(`${operation} failed:`, error);

      if (error.status === 404) {
        console.error(`${operation} not found`);
      } else if (error.status === 401) {
        console.error('Unauthorized access');
      }

      return of(result as T);
    };
  }
}
