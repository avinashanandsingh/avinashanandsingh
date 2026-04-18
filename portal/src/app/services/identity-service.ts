import { Injectable } from '@angular/core';
import { ApiService } from './api-service';
import { ActivatedRouteSnapshot, CanActivate, Router } from '@angular/router';
import { Header } from './header';
import { StorageService } from './storage-service';
import { jwtDecode } from 'jwt-decode';
@Injectable({
  providedIn: 'root',
})
export class IdentityService implements CanActivate {
  url: string = import.meta.env.NG_APP_API;
  user?: any;
  constructor(
    private router: Router,
    private header: Header,
    private store: StorageService,
    private api: ApiService,
  ) {}
  token() {
    return this.store.get('xt');
  }
  async exist(username: string): Promise<boolean> {
    let body = {
      query: 'query exist ($username: String!) { exist ( username: $username ) }',
      variables: {
        username: username,
      },
    };
    let header = this.header.api();
    let result: any = await this.api.post(this.url, header, body);    
    return result?.data?.exist;
  }

  async check(username: any, password: any): Promise<any> {
    let body = {
      query: 'query signin ($input:SignIn!) { signin (input:$input) }',
      variables: {
        input: {
          username: username,
          password: password,
        },
      },
    };
    let header = this.header.api();
    delete header['authorization'];
    return await this.api.post(this.url, header, body);
  }
  hasToken() {
    let token = this.token();
    return token !== null;
  }

  async isAuthenticated(): Promise<boolean> {
    let token = this.token() ?? '';
    let result: any;
    let flag: boolean = false;
    if (token.trim().length > 0) {
      let body = {
        query: 'query verify ($token: String!) { verify (token: $token) }',
        variables: {
          token: token,
        },
      };

      let header = this.header.api();
      result = await this.api.post(this.url!, header, body);
      flag = result?.data?.verify as boolean;
    }
    return flag;
  }

  async canActivate(route: ActivatedRouteSnapshot): Promise<boolean> {
    let authenticated = await this.isAuthenticated();
    //console.log("authenticated:", authenticated);
    //const isLoggedIn = localStorage.getItem('xt');
    let roles: string[] = route.data['roles'];
    if (authenticated) {
      this.user = jwtDecode(this.token());
      //console.log(this.user?.role);
      if (roles?.includes(this.user?.role)) {
        return true;
      } else {
        this.router.navigateByUrl('/unauthorized');
        return false;
      }
    } else {
      this.router.navigate(['/signin']);
      return false;
    }
  }

  async signup(entity: any): Promise<any> {
    let body = {
      query: 'mutation signup ($input: SignUp!){ signup(input: $input){ id } }',
      variables: {
        input: {
          first_name: entity.first_name,
          last_name: entity.last_name,
          email: entity.email,
          phone: entity.phone,
          password:  'V2JkMjk0NCM=',
        },
      },
    };
    let header = this.header.api();
    delete header['authorization'];
    return await this.api.post(this.url, header, body);
  }
}
