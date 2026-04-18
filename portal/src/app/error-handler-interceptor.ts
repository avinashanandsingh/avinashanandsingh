import { Injectable } from '@angular/core';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Router } from '@angular/router';

@Injectable()
export class ErrorHandlerInterceptor implements HttpInterceptor {

  constructor(private router: Router) {}

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    return next.handle(request).pipe(
      catchError((error: HttpErrorResponse) => {
        // Status 0 usually indicates a connection refused or network issue
        if (error.status === 0 || error.error instanceof ProgressEvent) {          
          // Redirect to a dedicated error page
          this.router.navigateByUrl('/unavailable');
        }
        
        // Rethrow the error for other handlers
        return throwError(() => error);
      })
    );
  }
}