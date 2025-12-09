import '../data/models/user_model.dart';

class PermissionsService {
  final User user;

  PermissionsService(this.user);

  // Roles
  bool get isAdmin => user.role.name == 'Administrador';
  bool get isTrainer => user.role.name == 'Entrenador';
  bool get isAthlete => user.role.name == 'Deportista';

  // Módulos disponibles
  bool get canAccessEvents => 
      isAdmin || 
      user.role.canView('appointmentManagement') ||
      user.role.canView('employeesSchedule');

  bool get canAccessAppointments => 
      isAdmin || 
      user.role.canView('appointmentManagement');

  bool get canAccessEmployees => 
      isAdmin || 
      user.role.canView('employeesSchedule');

  bool get canAccessAttendance => 
      isAdmin || 
      isTrainer;

  bool get canAccessSportsEquipment => 
      isAdmin || 
      user.role.canView('sportsEquipment');

  // Acciones específicas
  bool canCreateEvent() => 
      isAdmin || 
      user.role.canCreate('appointmentManagement');

  bool canEditEvent() => 
      isAdmin || 
      user.role.canEdit('appointmentManagement');

  bool canDeleteEvent() => 
      isAdmin || 
      user.role.canDelete('appointmentManagement');

  bool canCreateAppointment() => 
      isAdmin || 
      user.role.canCreate('appointmentManagement');

  bool canEditAppointment() => 
      isAdmin || 
      user.role.canEdit('appointmentManagement');

  bool canDeleteAppointment() => 
      isAdmin || 
      user.role.canDelete('appointmentManagement');

  // Helper genérico
  bool hasModulePermission(String module, String action) {
    if (isAdmin) return true;
    return user.role.hasPermission(module, action);
  }
}
