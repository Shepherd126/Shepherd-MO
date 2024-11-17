import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String? getEventStatus(String? status, AppLocalizations localizations) {
  switch (status) {
    case 'Đang duyệt':
      return localizations.pending;
    case 'Được thông qua':
      return localizations.accepted;
    case 'Không được thông qua':
      return localizations.rejected;
    case 'Đang diễn ra':
      return localizations.inProgress;
    case 'Quá hạn':
      return localizations.expired;
    case 'Chưa bắt đầu':
      return localizations.notStarted;
    default:
      return null;
  }
}
