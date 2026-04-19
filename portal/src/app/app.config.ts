import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';

import { routes } from './app.routes';
import { HTTP_INTERCEPTORS, provideHttpClient } from '@angular/common/http';
import { ErrorHandlerInterceptor } from './error-handler-interceptor';
import { provideSweetAlert2 } from '@sweetalert2/ngx-sweetalert2';
import { provideCodeEditor } from '@ngstack/code-editor';
export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideHttpClient(),
    { provide: HTTP_INTERCEPTORS, useClass: ErrorHandlerInterceptor, multi: true },   
    provideSweetAlert2({
      // Optional configuration
      fireOnInit: false,
      dismissOnDestroy: true,
    }),
    provideCodeEditor({ editorVersion: '0.44.0' })
  ],
};
