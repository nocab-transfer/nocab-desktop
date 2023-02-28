import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/base_job.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_dialog_cubit.dart';
import 'package:nocab_desktop/custom_dialogs/update_dialog/update_dialog_state.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher_string.dart';

extension S on UpdateDialogState {
  Size get size {
    switch (runtimeType) {
      case CheckingUpdate:
        return const Size(400, 300);
      case UpdateAvailable:
        return const Size(500, 500);
      case UpdateEvent:
        return Size(850, ((this as UpdateEvent).jobs.length * 74) + 32);
      default:
        return const Size(300, 300);
    }
  }
}

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BlocProvider(
        create: (context) => UpdateDialogCubit()..check(),
        child: BlocConsumer<UpdateDialogCubit, UpdateDialogState>(
          listener: (context, state) {},
          builder: (context, state) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              height: state.size.height,
              width: state.size.width,
              child: builder(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget builder(context, state) {
    switch (state.runtimeType) {
      case CheckingUpdate:
        return buildCheckingUpdate(context, state);
      case CheckError:
        return buildCheckError(context, state);
      case UpdateAvailable:
        return buildUpdateAvailable(context, state);
      case UpdateEvent:
        return buildUpdating(context, state);
      default:
        return Container();
    }
  }

  Widget buildCheckingUpdate(BuildContext context, CheckingUpdate update) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text('update.dialog.checking.title'.tr(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Text('update.dialog.checking.message'.tr(), style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  Widget buildCheckError(BuildContext context, CheckError error) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(0),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😿', style: TextStyle(fontSize: 48)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text("update.dialog.checkError.title".tr(), style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "update.dialog.checkError.error".tr(namedArgs: {'error': error.message}),
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  "${error.error}",
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ).animate(delay: 150.ms).fadeIn(),
      ],
    );
  }

  Widget buildUpdateAvailable(BuildContext context, UpdateAvailable update) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(0),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('update.dialog.updateAvailable.title'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "update.dialog.updateAvailable.version".tr(namedArgs: {
                        'currentVersion': update.currentVersion,
                        'newVersion': update.newVersion.replaceAll('v', ''),
                      }),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 200,
                    child: Markdown(
                      inlineSyntaxes: md.ExtensionSet.gitHubWeb.inlineSyntaxes,
                      blockSyntaxes: md.ExtensionSet.gitHubWeb.blockSyntaxes,
                      onTapLink: (text, href, title) => launchUrlString(href!),
                      styleSheet: MarkdownStyleSheet(
                        blockquoteDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
                        ),
                      ),
                      data: update.releaseNotes,
                      extensionSet: md.ExtensionSet.gitHubWeb,
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: [
                    if (!update.isMsixInstalled) ...[
                      Text(
                        "update.dialog.updateAvailable.switchToMsixMessage".tr(),
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            surfaceTintColor: Theme.of(context).colorScheme.error,
                            fixedSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            side: BorderSide(width: 2, color: Theme.of(context).colorScheme.error),
                          ),
                          child: Text(
                            'update.dialog.updateAvailable.cancelButton'.tr(),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => context.read<UpdateDialogCubit>().update(msixInstalled: update.isMsixInstalled),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            (update.isMsixInstalled
                                    ? 'update.dialog.updateAvailable.updateButton'
                                    : 'update.dialog.updateAvailable.switchToMsixButton')
                                .tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.background),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate(delay: 150.ms).fadeIn();
  }

  Widget buildUpdating(BuildContext context, UpdateEvent event) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Row(
            children: [
              Flexible(
                flex: 7,
                child: Center(
                  child: ListView.builder(
                    itemCount: event.jobs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final job = event.jobs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 66,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: job.status.color(context),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: job.status.icon(context),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "update.dialog.updating.jobs.${job.translationMasterKey}.title".tr(),
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "update.dialog.updating.jobs.${job.translationMasterKey}.${job.descTranslationKey}".tr(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (job.status == UpdateJobStatus.done || job.status == UpdateJobStatus.failed) ...[
                                        SizedBox(
                                          width: 50,
                                          child: Text(
                                            "update.dialog.updating.seconds".tr(namedArgs: {'seconds': (job.milliseconds / 1000).toStringAsFixed(2)}),
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 4,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (event.anyFailed) ...[
                          const Text('😿', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                          Text('update.dialog.updating.panel.failed.title'.tr(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            "update.dialog.updating.panel.failed.crashedAt".tr(
                              namedArgs: {'job': "update.dialog.updating.jobs.${event.crashedJob.translationMasterKey}.title".tr()},
                            ),
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: event.size.height / 4),
                            child: SingleChildScrollView(
                              child: Text(
                                "update.dialog.updating.panel.failed.errorMessage".tr(
                                  namedArgs: {'message': event.crashedJob.errorMessage.toString()},
                                ),
                                style: Theme.of(context).textTheme.labelMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(100, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(
                              'update.dialog.updating.panel.failed.closeButton'.tr(),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.background),
                            ),
                          ),
                        ] else ...[
                          const Text('🚀', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('update.dialog.updating.panel.ongoing.title'.tr(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('update.dialog.updating.panel.ongoing.description'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: 150.ms).fadeIn();
  }
}
