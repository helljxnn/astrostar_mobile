//Archivo temporal para simular datos de usuario
class CurrentUser { 
  static String email = 'astrostarmovil@gmail.com';
  static String name = 'Juan';
  static String lastName = 'Pérez';
  static int avatarColorIndex = 0;
  
  // Método para actualizar datos (opcional para el futuro)
  static void updateProfile(String name, String lastName, int colorIndex) {
    CurrentUser.name = name;
    CurrentUser.lastName = lastName;
    CurrentUser.avatarColorIndex = colorIndex;
  }
} 