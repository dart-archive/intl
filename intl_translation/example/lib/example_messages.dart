// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// An example to demonstrate the output from `bin/generate_from_arb.dart`.

import 'package:intl/intl.dart';

import 'generated/messages_all.dart';

void main(List<String> args) async {
  var locale = args.isNotEmpty ? args[0] : Intl.defaultLocale;

  await initializeMessages(locale);

  print("Displaying messages for the '$locale' locale:");
  print('');

  Intl.withLocale(locale, () {
    printMessages();
  });
}

void printMessages() {
  show(Intl.message('scriptCategory'));
  show(Intl.message('timeOfDayFormat'));
  show(Intl.message('openAppDrawerTooltip'));
  show(Intl.message('backButtonTooltip'));
  show(Intl.message('closeButtonTooltip'));
  show(Intl.message('deleteButtonTooltip'));
  show(Intl.message('moreButtonTooltip'));
  show(Intl.message('nextMonthTooltip'));
  show(Intl.message('previousMonthTooltip'));
  show(Intl.message('nextPageTooltip'));
  show(Intl.message('previousPageTooltip'));
  show(Intl.message('firstPageTooltip'));
  show(Intl.message('lastPageTooltip'));
  show(Intl.message('showMenuTooltip'));
  show(Intl.message('aboutListTileTitle'));
  show(Intl.message('licensesPageTitle'));
  show(Intl.message('licensesPackageDetailTextZero'));
  show(Intl.message('licensesPackageDetailTextOne'));
  show(Intl.message('licensesPackageDetailTextOther'));
  show(Intl.message('pageRowsInfoTitle'));
  show(Intl.message('pageRowsInfoTitleApproximate'));
  show(Intl.message('rowsPerPageTitle'));
  show(Intl.message('tabLabel'));
  show(Intl.message('selectedRowCountTitleZero'));
  show(Intl.message('selectedRowCountTitleOne'));
  show(Intl.message('selectedRowCountTitleOther'));
  show(Intl.message('cancelButtonLabel'));
  show(Intl.message('closeButtonLabel'));
  show(Intl.message('continueButtonLabel'));
  show(Intl.message('copyButtonLabel'));
  show(Intl.message('cutButtonLabel'));
  show(Intl.message('okButtonLabel'));
  show(Intl.message('pasteButtonLabel'));
  show(Intl.message('selectAllButtonLabel'));
  show(Intl.message('viewLicensesButtonLabel'));
  show(Intl.message('anteMeridiemAbbreviation'));
  show(Intl.message('postMeridiemAbbreviation'));
  show(Intl.message('timePickerHourModeAnnouncement'));
  show(Intl.message('timePickerMinuteModeAnnouncement'));
  show(Intl.message('modalBarrierDismissLabel'));
  show(Intl.message('dateSeparator'));
  show(Intl.message('dateHelpText'));
  show(Intl.message('selectYearSemanticsLabel'));
  show(Intl.message('unspecifiedDate'));
  show(Intl.message('unspecifiedDateRange'));
  show(Intl.message('dateInputLabel'));
  show(Intl.message('dateRangeStartLabel'));
  show(Intl.message('dateRangeEndLabel'));
  show(Intl.message('dateRangeStartDateSemanticLabel'));
  show(Intl.message('dateRangeEndDateSemanticLabel'));
  show(Intl.message('invalidDateFormatLabel'));
  show(Intl.message('invalidDateRangeLabel'));
  show(Intl.message('dateOutOfRangeLabel'));
  show(Intl.message('saveButtonLabel'));
  show(Intl.message('datePickerHelpText'));
  show(Intl.message('dateRangePickerHelpText'));
  show(Intl.message('calendarModeButtonLabel'));
  show(Intl.message('inputDateModeButtonLabel'));
  show(Intl.message('timePickerDialHelpText'));
  show(Intl.message('timePickerInputHelpText'));
  show(Intl.message('timePickerHourLabel'));
  show(Intl.message('timePickerMinuteLabel'));
  show(Intl.message('invalidTimeLabel'));
  show(Intl.message('dialModeButtonLabel'));
  show(Intl.message('inputTimeModeButtonLabel'));
  show(Intl.message('signedInLabel'));
  show(Intl.message('hideAccountsLabel'));
  show(Intl.message('showAccountsLabel'));
  show(Intl.message('drawerLabel'));
  show(Intl.message('menuBarMenuLabel'));
  show(Intl.message('popupMenuLabel'));
  show(Intl.message('dialogLabel'));
  show(Intl.message('alertDialogLabel'));
  show(Intl.message('searchFieldLabel'));
  show(Intl.message('reorderItemToStart'));
  show(Intl.message('reorderItemToEnd'));
  show(Intl.message('reorderItemUp'));
  show(Intl.message('reorderItemDown'));
  show(Intl.message('reorderItemLeft'));
  show(Intl.message('reorderItemRight'));
  show(Intl.message('expandedIconTapHint'));
  show(Intl.message('collapsedIconTapHint'));
  show(Intl.message('remainingTextFieldCharacterCountZero'));
  show(Intl.message('remainingTextFieldCharacterCountOne'));
  show(Intl.message('remainingTextFieldCharacterCountOther'));
  show(Intl.message('refreshIndicatorSemanticLabel'));
  show(Intl.message('keyboardKeyAlt'));
  show(Intl.message('keyboardKeyAltGraph'));
  show(Intl.message('keyboardKeyBackspace'));
  show(Intl.message('keyboardKeyCapsLock'));
  show(Intl.message('keyboardKeyChannelDown'));
  show(Intl.message('keyboardKeyChannelUp'));
  show(Intl.message('keyboardKeyControl'));
  show(Intl.message('keyboardKeyDelete'));
  show(Intl.message('keyboardKeyEject'));
  show(Intl.message('keyboardKeyEnd'));
  show(Intl.message('keyboardKeyEscape'));
  show(Intl.message('keyboardKeyFn'));
  show(Intl.message('keyboardKeyHome'));
  show(Intl.message('keyboardKeyInsert'));
  show(Intl.message('keyboardKeyMeta'));
  show(Intl.message('keyboardKeyMetaMacOs'));
  show(Intl.message('keyboardKeyMetaWindows'));
  show(Intl.message('keyboardKeyNumLock'));
  show(Intl.message('keyboardKeyNumpad1'));
  show(Intl.message('keyboardKeyNumpad2'));
  show(Intl.message('keyboardKeyNumpad3'));
  show(Intl.message('keyboardKeyNumpad4'));
  show(Intl.message('keyboardKeyNumpad5'));
  show(Intl.message('keyboardKeyNumpad6'));
  show(Intl.message('keyboardKeyNumpad7'));
  show(Intl.message('keyboardKeyNumpad8'));
  show(Intl.message('keyboardKeyNumpad9'));
  show(Intl.message('keyboardKeyNumpad0'));
  show(Intl.message('keyboardKeyNumpadAdd'));
  show(Intl.message('keyboardKeyNumpadComma'));
  show(Intl.message('keyboardKeyNumpadDecimal'));
  show(Intl.message('keyboardKeyNumpadDivide'));
  show(Intl.message('keyboardKeyNumpadEnter'));
  show(Intl.message('keyboardKeyNumpadEqual'));
  show(Intl.message('keyboardKeyNumpadMultiply'));
  show(Intl.message('keyboardKeyNumpadParenLeft'));
  show(Intl.message('keyboardKeyNumpadParenRight'));
  show(Intl.message('keyboardKeyNumpadSubtract'));
  show(Intl.message('keyboardKeyPageDown'));
  show(Intl.message('keyboardKeyPageUp'));
  show(Intl.message('keyboardKeyPower'));
  show(Intl.message('keyboardKeyPowerOff'));
  show(Intl.message('keyboardKeyPrintScreen'));
  show(Intl.message('keyboardKeyScrollLock'));
  show(Intl.message('keyboardKeySelect'));
  show(Intl.message('keyboardKeySpace'));
}

void show(String message) {
  print(" - '$message'");
}
