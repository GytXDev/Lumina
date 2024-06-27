import 'package:intl/intl.dart';
import 'package:lumina/features/auth/widgets/custom_button.dart';
import 'package:lumina/languages/app_translations.dart';
import 'package:lumina/models/order_model.dart';
import 'package:flutter/material.dart';

class CustomOrderItem extends StatelessWidget {
  final Function()? onMarkAsSoldPressed; // Pour l'admin
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
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: onDetailPressed,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        order.carImages[0],
                        width: 100,
                        height: 100,
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
                      ),
                      /*const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context).translate('saler')} ${order.username}',
                        ),*/
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.of(context).translate('requestDate')} ${DateFormat('dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(order.orderTime)}',
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
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
