import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_widgets/transfer_card_bloc/transfer_card_state.dart';
import 'package:nocab_desktop/l10n/generated/app_localizations.dart';

class TransferFailedView extends StatelessWidget {
  final TransferFailed state;
  final bool isDownload;
  final Function()? onClose;
  const TransferFailedView({Key? key, required this.state, required this.isDownload, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                        width: MediaQuery.of(context).size.height / 15,
                        child: Icon(Icons.phonelink_rounded, color: Theme.of(context).colorScheme.primary),
                      ),
                      SizedBox(
                        width: 250,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.deviceInfo.name ?? "Unknown", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              Text(state.deviceInfo.ip ?? "", style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Tooltip(
                    message: AppLocalizations.of(context).removeButtonTooltip,
                    child: Material(
                      child: InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(10),
                        hoverColor: Theme.of(context).colorScheme.primary.withAlpha(40),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context).transferErrorLabelText, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
