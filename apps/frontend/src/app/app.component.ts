import { User } from '@leihgut/zod-schemas';
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'frontend';

  ngOnInit() {
    const user: User = {
      name: 'test',
    };
  }
}
