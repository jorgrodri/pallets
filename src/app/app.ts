import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  imports: [],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal(' Ing Jorge Rodriguez ');

  // Función para manejar el envío del formulario de contacto
  public handleContactFormSubmit(event: Event): void {
    event.preventDefault();
    const form = event.target as HTMLFormElement;
    const formData = new FormData(form);

    const name = formData.get('name') as string;
    const email = formData.get('email') as string;
    const message = formData.get('message') as string;

    // Aquí puedes agregar la lógica para enviar los datos del formulario
    // Por ejemplo, enviarlos a un servidor o mostrar una confirmación
    console.log('Nombre:', name);
    console.log('Email:', email);
    console.log('Mensaje:', message);

    // Limpiar el formulario después de enviar
    form.reset();
  }
}
