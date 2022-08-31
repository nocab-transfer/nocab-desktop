import 'dart:io';

import 'package:nocab_desktop/custom_widgets/file_list/file_list.dart';
import 'package:nocab_desktop/models/file_model.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/services/server/server.dart';

class FileAccepterDialog extends StatefulWidget {
  final ShareRequest request;
  final Socket socket;
  const FileAccepterDialog({Key? key, required this.request, required this.socket}) : super(key: key);

  @override
  State<FileAccepterDialog> createState() => _FileAccepterDialogState();
}

class _FileAccepterDialogState extends State<FileAccepterDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        //height: 500,
        width: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                height: 100,
                child: Center(
                    child: Icon(
                  Icons.file_present_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
              ),
              Text(
                "${widget.request.deviceInfo.name ?? "Unknown"} wants to send you a file",
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Ip: ${widget.socket.remoteAddress.address} - Port: ${widget.socket.remotePort}",
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                width: 400,
                height: MediaQuery.of(context).size.width / 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: FileList(files: widget.request.files),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Server().rejectRequest(widget.request, widget.socket).then((value) => Navigator.pop(context)),
                    style: OutlinedButton.styleFrom(
                      surfaceTintColor: Theme.of(context).colorScheme.error,
                      fixedSize: const Size(100, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      side: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
                    ),
                    child: Text(
                      "Reject",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Server().acceptRequest(widget.request, widget.socket).then((value) => Navigator.pop(context)),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(100, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                    child: Text(
                      "Accept",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
