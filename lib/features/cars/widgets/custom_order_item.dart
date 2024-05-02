import 'package:intl/intl.dart';
import 'package:lumina/colors/coloors.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class CustomOrderItem extends StatelessWidget {
  final Function()? onMarkAsSoldPressed; // Pour l'admin
  final Function()? onReportOrderPressed; // Pour l'utilisateur
  final OrderCars order;
  final Function() onDeletePressed;
  final Function() onDetailPressed;
  final bool showBellIcon;

  const CustomOrderItem({
    super.key,
    required this.order,
    required this.onDeletePressed,
    required this.onDetailPressed,
    this.onMarkAsSoldPressed,
    this.onReportOrderPressed,
    this.showBellIcon = false,
  });

  String formatPrice(double price, Locale locale) {
    final format = NumberFormat("#,###", locale.toString());
    // ignore: avoid_print
    print('$locale');
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(order.orderId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDeletePressed();
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDeletePressed();
        }
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: onDetailPressed,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        order.carImages[0],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        '${order.brand} ${order.carName}, ${formatPrice(order.price, Localizations.localeOf(context))} ${order.orderCurrency}',
                        style: const TextStyle(color: Coolors.greyDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.of(context).translate('saler')} ${order.username}', // Ajoute cette ligne pour afficher le nom d'utilisateur
                        style: const TextStyle(color: Coolors.greyDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.of(context).translate('requestDate')} ${DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(order.orderTime)}',
                        style: const TextStyle(color: Coolors.greyDark),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
            // Ajoutez cette partie pour afficher l'icône de cloche si showBellIcon est true
            if (showBellIcon)
              const Icon(
                Icons.notifications,
                color: Colors.orange, // Couleur de l'icône de cloche
              ),
            if (order.isAlert == false && onReportOrderPressed != null)
              ElevatedButton(
                onPressed: () {
                  QuickAlert.show(
                      onCancelBtnTap: () {
                        Navigator.pop(context);
                      },
                      context: context,
                      type: QuickAlertType.confirm,
                      title: AppLocalizations.of(context)
                          .translate('markAsPaidConfirmationTitle'),
                      text: AppLocalizations.of(context)
                          .translate('reportAsBoughtConfirmationText'),
                      textAlignment: TextAlign.center,
                      confirmBtnText: AppLocalizations.of(context)
                          .translate('markAsPaidConfirmationYes'),
                      cancelBtnText: AppLocalizations.of(context)
                          .translate('markAsPaidConfirmationNo'),
                      confirmBtnColor: Coolors.blueDark,
                      backgroundColor: Coolors.greyDark,
                      headerBackgroundColor: Colors.grey,
                      confirmBtnTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      cancelBtnTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      titleColor: Colors.white,
                      textColor: Colors.white,
                      onConfirmBtnTap: onReportOrderPressed);
                },
                child: Text(
                    AppLocalizations.of(context).translate('reportAsBought')),
              ),

            if (order.isAlert == true)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  AppLocalizations.of(context).translate('orderReported'),
                  style: const TextStyle(),
                ),
              ),
            if (onMarkAsSoldPressed != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: CustomElevatedButton(
                  onPressed: () {
                    if (onMarkAsSoldPressed != null) {
                      onMarkAsSoldPressed!();
                    }
                  },
                  text: AppLocalizations.of(context).translate('markAsSold'),
                ),
              ),

            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
