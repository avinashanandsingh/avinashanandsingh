import { Component } from '@angular/core';

@Component({
  selector: 'app-unauthorized',
  imports: [],
  templateUrl: './unauthorized.html',
  styleUrl: './unauthorized.css',
})
export class Unauthorized {
  title = 'Access Restricted';
  status = '403 Forbidden';
  message = 'You do not have the necessary permissions to access this resource.';
  instruction = 'Please contact your administrator or check your subscription tier.';
  
  redirectUrl = '/signin';
}
