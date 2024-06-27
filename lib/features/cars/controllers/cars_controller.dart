

import '../../../models/cars_model.dart';
import '../repository/cars_repository.dart';

class CarsController {
  final CarsRepository _repository = CarsRepository();

  Future<void> saveCar(CarsModel car) async {
    try {
      await _repository.saveCarToCollection(car);
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de l\'enregistrement de la voiture : $e');
      // Gérer l'erreur
    }
  }
}
