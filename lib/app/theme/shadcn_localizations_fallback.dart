import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
// ignore: implementation_imports
import 'package:shadcn_flutter/src/components/locale/shadcn_localizations_en.dart';
import 'package:intl/intl.dart' as intl;

class FallbackShadcnLocalizationsDelegate
    extends LocalizationsDelegate<ShadcnLocalizations> {
  const FallbackShadcnLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<ShadcnLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return SynchronousFuture<ShadcnLocalizations>(ShadcnLocalizationsTr());
      case 'ru':
        return SynchronousFuture<ShadcnLocalizations>(ShadcnLocalizationsRu());
      default:
        return SynchronousFuture<ShadcnLocalizations>(ShadcnLocalizationsEn());
    }
  }

  @override
  bool shouldReload(FallbackShadcnLocalizationsDelegate old) => false;
}

class ShadcnLocalizationsTr extends ShadcnLocalizations {
  ShadcnLocalizationsTr([super.locale = 'tr']);

  @override
  String get noSpellCheckReplacements => 'Öneri bulunamadı';

  @override
  String get formNotEmpty => 'Bu alan boş bırakılamaz';

  @override
  String get invalidValue => 'Geçersiz değer';

  @override
  String get invalidEmail => 'Geçersiz e-posta';

  @override
  String get invalidURL => 'Geçersiz URL';

  @override
  String formLessThan(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return '$valueString değerinden küçük olmalıdır';
  }

  @override
  String formGreaterThan(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return '$valueString değerinden büyük olmalıdır';
  }

  @override
  String formLessThanOrEqualTo(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return '$valueString değerinden küçük veya eşit olmalıdır';
  }

  @override
  String get formPhoneNumberInvalid => 'Telefon numarası geçersiz';

  @override
  String get formPhoneNumberEmpty => 'Telefon numarası gereklidir';

  @override
  String formGreaterThanOrEqualTo(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return '$valueString değerinden büyük veya eşit olmalıdır';
  }

  @override
  String formBetweenInclusively(double min, double max) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String minString = minNumberFormat.format(min);
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);
    return '$minString ile $maxString arasında olmalıdır (dahil)';
  }

  @override
  String formBetweenExclusively(double min, double max) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String minString = minNumberFormat.format(min);
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);
    return '$minString ile $maxString arasında olmalıdır (hariç)';
  }

  @override
  String formLengthLessThan(int value) {
    return 'En az $value karakter olmalıdır';
  }

  @override
  String formLengthGreaterThan(int value) {
    return 'En fazla $value karakter olmalıdır';
  }

  @override
  String get formPasswordDigits => 'En az bir rakam içermelidir';

  @override
  String get formPasswordLowercase => 'En az bir küçük harf içermelidir';

  @override
  String get formPasswordUppercase => 'En az bir büyük harf içermelidir';

  @override
  String get formPasswordSpecial => 'En az bir özel karakter içermelidir';

  @override
  String get commandSearch => 'Komut yazın veya arayın...';

  @override
  String get commandEmpty => 'Sonuç bulunamadı.';

  @override
  String get datePickerSelectYear => 'Yıl seçin';

  @override
  String get abbreviatedMonday => 'Pzt';

  @override
  String get abbreviatedTuesday => 'Sal';

  @override
  String get abbreviatedWednesday => 'Çar';

  @override
  String get abbreviatedThursday => 'Per';

  @override
  String get abbreviatedFriday => 'Cum';

  @override
  String get abbreviatedSaturday => 'Cmt';

  @override
  String get abbreviatedSunday => 'Paz';

  @override
  String get monthJanuary => 'Ocak';

  @override
  String get monthFebruary => 'Şubat';

  @override
  String get monthMarch => 'Mart';

  @override
  String get monthApril => 'Nisan';

  @override
  String get monthMay => 'Mayıs';

  @override
  String get monthJune => 'Haziran';

  @override
  String get monthJuly => 'Temmuz';

  @override
  String get monthAugust => 'Ağustos';

  @override
  String get monthSeptember => 'Eylül';

  @override
  String get monthOctober => 'Ekim';

  @override
  String get monthNovember => 'Kasım';

  @override
  String get monthDecember => 'Aralık';

  @override
  String get abbreviatedJanuary => 'Oca';

  @override
  String get abbreviatedFebruary => 'Şub';

  @override
  String get abbreviatedMarch => 'Mar';

  @override
  String get abbreviatedApril => 'Nis';

  @override
  String get abbreviatedMay => 'May';

  @override
  String get abbreviatedJune => 'Haz';

  @override
  String get abbreviatedJuly => 'Tem';

  @override
  String get abbreviatedAugust => 'Ağu';

  @override
  String get abbreviatedSeptember => 'Eyl';

  @override
  String get abbreviatedOctober => 'Eki';

  @override
  String get abbreviatedNovember => 'Kas';

  @override
  String get abbreviatedDecember => 'Ara';

  @override
  String get buttonCancel => 'İptal';

  @override
  String get buttonSave => 'Kaydet';

  @override
  String get timeHour => 'Saat';

  @override
  String get timeMinute => 'Dakika';

  @override
  String get timeSecond => 'Saniye';

  @override
  String get timeAM => 'ÖÖ';

  @override
  String get timePM => 'ÖS';

  @override
  String get colorRed => 'Kırmızı';

  @override
  String get colorGreen => 'Yeşil';

  @override
  String get colorBlue => 'Mavi';

  @override
  String get colorAlpha => 'Alfa';

  @override
  String get colorHue => 'Ton';

  @override
  String get colorSaturation => 'Doygunluk';

  @override
  String get colorValue => 'Değer';

  @override
  String get colorLightness => 'Açıklık';

  @override
  String get menuCut => 'Kes';

  @override
  String get menuCopy => 'Kopyala';

  @override
  String get menuPaste => 'Yapıştır';

  @override
  String get menuSelectAll => 'Tümünü Seç';

  @override
  String get menuUndo => 'Geri Al';

  @override
  String get menuRedo => 'Yinele';

  @override
  String get menuDelete => 'Sil';

  @override
  String get menuShare => 'Paylaş';

  @override
  String get menuSearchWeb => 'Web\'de Ara';

  @override
  String get menuLiveTextInput => 'Canlı Metin Girişi';

  @override
  String get placeholderDatePicker => 'Tarih seçin';

  @override
  String get placeholderTimePicker => 'Saat seçin';

  @override
  String get placeholderColorPicker => 'Renk seçin';

  @override
  String get buttonPrevious => 'Önceki';

  @override
  String get buttonNext => 'Sonraki';

  @override
  String get refreshTriggerPull => 'Yenilemek için çekin';

  @override
  String get refreshTriggerRelease => 'Yenilemek için bırakın';

  @override
  String get refreshTriggerRefreshing => 'Yenileniyor...';

  @override
  String get refreshTriggerComplete => 'Yenileme tamamlandı';

  @override
  String get colorPickerTabRecent => 'Son Kullanılanlar';

  @override
  String get colorPickerTabRGB => 'RGB';

  @override
  String get colorPickerTabHSV => 'HSV';

  @override
  String get colorPickerTabHSL => 'HSL';

  @override
  String get colorPickerTabHEX => 'HEX';

  @override
  String get commandMoveUp => 'Yukarı Taşı';

  @override
  String get commandMoveDown => 'Aşağı Taşı';

  @override
  String get commandActivate => 'Seç';

  @override
  String dataTableSelectedRows(int count, int total) {
    return '$total satırdan $count tanesi seçildi.';
  }

  @override
  String get dataTableNext => 'Sonraki';

  @override
  String get dataTablePrevious => 'Önceki';

  @override
  String get dataTableColumns => 'Sütunlar';

  @override
  String get timeDaysAbbreviation => 'GG';

  @override
  String get timeHoursAbbreviation => 'SS';

  @override
  String get timeMinutesAbbreviation => 'DD';

  @override
  String get timeSecondsAbbreviation => 'SN';

  @override
  String get placeholderDurationPicker => 'Süre seçin';

  @override
  String get durationDay => 'Gün';

  @override
  String get durationHour => 'Saat';

  @override
  String get durationMinute => 'Dakika';

  @override
  String get durationSecond => 'Saniye';
}

class ShadcnLocalizationsRu extends ShadcnLocalizations {
  ShadcnLocalizationsRu([super.locale = 'ru']);

  @override
  String get noSpellCheckReplacements => 'Замены не найдены';

  @override
  String get formNotEmpty => 'Это поле не может быть пустым';

  @override
  String get invalidValue => 'Недопустимое значение';

  @override
  String get invalidEmail => 'Некорректный email';

  @override
  String get invalidURL => 'Некорректный URL';

  @override
  String formLessThan(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return 'Должно быть меньше $valueString';
  }

  @override
  String formGreaterThan(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return 'Должно быть больше $valueString';
  }

  @override
  String formLessThanOrEqualTo(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return 'Должно быть меньше или равно $valueString';
  }

  @override
  String get formPhoneNumberInvalid => 'Неверный номер телефона';

  @override
  String get formPhoneNumberEmpty => 'Номер телефона обязателен';

  @override
  String formGreaterThanOrEqualTo(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    return 'Должно быть больше или равно $valueString';
  }

  @override
  String formBetweenInclusively(double min, double max) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String minString = minNumberFormat.format(min);
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);
    return 'Должно быть между $minString и $maxString (включительно)';
  }

  @override
  String formBetweenExclusively(double min, double max) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String minString = minNumberFormat.format(min);
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);
    return 'Должно быть между $minString и $maxString (исключительно)';
  }

  @override
  String formLengthLessThan(int value) {
    return 'Должно быть не менее $value символов';
  }

  @override
  String formLengthGreaterThan(int value) {
    return 'Должно быть не более $value символов';
  }

  @override
  String get formPasswordDigits => 'Должен содержать хотя бы одну цифру';

  @override
  String get formPasswordLowercase =>
      'Должен содержать хотя бы одну строчную букву';

  @override
  String get formPasswordUppercase =>
      'Должен содержать хотя бы одну заглавную букву';

  @override
  String get formPasswordSpecial =>
      'Должен содержать хотя бы один специальный символ';

  @override
  String get commandSearch => 'Введите команду или поиск...';

  @override
  String get commandEmpty => 'Ничего не найдено.';

  @override
  String get datePickerSelectYear => 'Выберите год';

  @override
  String get abbreviatedMonday => 'Пн';

  @override
  String get abbreviatedTuesday => 'Вт';

  @override
  String get abbreviatedWednesday => 'Ср';

  @override
  String get abbreviatedThursday => 'Чт';

  @override
  String get abbreviatedFriday => 'Пт';

  @override
  String get abbreviatedSaturday => 'Сб';

  @override
  String get abbreviatedSunday => 'Вс';

  @override
  String get monthJanuary => 'Январь';

  @override
  String get monthFebruary => 'Февраль';

  @override
  String get monthMarch => 'Март';

  @override
  String get monthApril => 'Апрель';

  @override
  String get monthMay => 'Май';

  @override
  String get monthJune => 'Июнь';

  @override
  String get monthJuly => 'Июль';

  @override
  String get monthAugust => 'Август';

  @override
  String get monthSeptember => 'Сентябрь';

  @override
  String get monthOctober => 'Октябрь';

  @override
  String get monthNovember => 'Ноябрь';

  @override
  String get monthDecember => 'Декабрь';

  @override
  String get abbreviatedJanuary => 'Янв';

  @override
  String get abbreviatedFebruary => 'Фев';

  @override
  String get abbreviatedMarch => 'Мар';

  @override
  String get abbreviatedApril => 'Апр';

  @override
  String get abbreviatedMay => 'Май';

  @override
  String get abbreviatedJune => 'Июн';

  @override
  String get abbreviatedJuly => 'Июл';

  @override
  String get abbreviatedAugust => 'Авг';

  @override
  String get abbreviatedSeptember => 'Сен';

  @override
  String get abbreviatedOctober => 'Окт';

  @override
  String get abbreviatedNovember => 'Ноя';

  @override
  String get abbreviatedDecember => 'Дек';

  @override
  String get buttonCancel => 'Отмена';

  @override
  String get buttonSave => 'Сохранить';

  @override
  String get timeHour => 'Час';

  @override
  String get timeMinute => 'Минута';

  @override
  String get timeSecond => 'Секунда';

  @override
  String get timeAM => 'ДП';

  @override
  String get timePM => 'ПП';

  @override
  String get colorRed => 'Красный';

  @override
  String get colorGreen => 'Зеленый';

  @override
  String get colorBlue => 'Синий';

  @override
  String get colorAlpha => 'Альфа';

  @override
  String get colorHue => 'Оттенок';

  @override
  String get colorSaturation => 'Насыщенность';

  @override
  String get colorValue => 'Значение';

  @override
  String get colorLightness => 'Яркость';

  @override
  String get menuCut => 'Вырезать';

  @override
  String get menuCopy => 'Копировать';

  @override
  String get menuPaste => 'Вставить';

  @override
  String get menuSelectAll => 'Выбрать все';

  @override
  String get menuUndo => 'Отменить';

  @override
  String get menuRedo => 'Повторить';

  @override
  String get menuDelete => 'Удалить';

  @override
  String get menuShare => 'Поделиться';

  @override
  String get menuSearchWeb => 'Искать в Интернете';

  @override
  String get menuLiveTextInput => 'Ввод текста';

  @override
  String get placeholderDatePicker => 'Выберите дату';

  @override
  String get placeholderTimePicker => 'Выберите время';

  @override
  String get placeholderColorPicker => 'Выберите цвет';

  @override
  String get buttonPrevious => 'Назад';

  @override
  String get buttonNext => 'Вперед';

  @override
  String get refreshTriggerPull => 'Потяните для обновления';

  @override
  String get refreshTriggerRelease => 'Отпустите для обновления';

  @override
  String get refreshTriggerRefreshing => 'Обновление...';

  @override
  String get refreshTriggerComplete => 'Обновлено';

  @override
  String get colorPickerTabRecent => 'Недавние';

  @override
  String get colorPickerTabRGB => 'RGB';

  @override
  String get colorPickerTabHSV => 'HSV';

  @override
  String get colorPickerTabHSL => 'HSL';

  @override
  String get colorPickerTabHEX => 'HEX';

  @override
  String get commandMoveUp => 'Вверх';

  @override
  String get commandMoveDown => 'Вниз';

  @override
  String get commandActivate => 'Выбрать';

  @override
  String dataTableSelectedRows(int count, int total) {
    return 'Выбрано строк: $count из $total.';
  }

  @override
  String get dataTableNext => 'Вперед';

  @override
  String get dataTablePrevious => 'Назад';

  @override
  String get dataTableColumns => 'Колонки';

  @override
  String get timeDaysAbbreviation => 'ДД';

  @override
  String get timeHoursAbbreviation => 'ЧЧ';

  @override
  String get timeMinutesAbbreviation => 'ММ';

  @override
  String get timeSecondsAbbreviation => 'СС';

  @override
  String get placeholderDurationPicker => 'Выберите длительность';

  @override
  String get durationDay => 'День';

  @override
  String get durationHour => 'Час';

  @override
  String get durationMinute => 'Минута';

  @override
  String get durationSecond => 'Секунда';
}
