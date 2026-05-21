/// Utilidades para calcular costos de renta por hora.
class RentalCalculation {
  RentalCalculation._();

  /// Horas entre inicio y fin (mínimo 1 hora).
  static int hoursBetween(DateTime start, DateTime end) {
    final startAt = DateTime(start.year, start.month, start.day);
    final endAt = DateTime(end.year, end.month, end.day, 23, 59, 59);
    var hours = endAt.difference(startAt).inHours;
    if (hours < 1) hours = 1;
    return hours;
  }

  static double totalCost(DateTime start, DateTime end, double hourlyRate) {
    return hoursBetween(start, end) * hourlyRate;
  }
}
