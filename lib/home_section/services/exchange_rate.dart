// exchange_rate.dart
import 'currency.dart';

class ExchangeRate {
  static final Map<Currency, double> rates = {
    Currency.USD: 1.0,
    Currency.Euro: 1.12,
    Currency.XAF: 0.0017,
    Currency.Rand: 0.065,
    Currency.Naira: 0.0024,
    Currency.Dirham: 0.27,
    Currency.Shilling: 0.0089,
    Currency.Kwacha: 0.0012,
    Currency.Birr: 0.023,
    Currency.Dinar: 0.0073,
  };

  /// Convertit un montant d'une devise source à une devise cible.
  /// [amount] le montant à convertir.
  /// [rate] la devise source.
  /// [to] la devise cible.
  /// Retourne le montant converti.
  static double convertToUSD(double amount, Currency currency) {
    double rate = rates[currency] ?? 1.0; // Utilise 1.0 pour USD comme fallback
    double convertedAmount = amount * rate; // Convertit directement en USD
    // ignore: avoid_print
    print("Converting $amount from $currency to USD: $convertedAmount");
    return convertedAmount;
  }
}
