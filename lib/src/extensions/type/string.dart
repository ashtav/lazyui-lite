part of '../extension.dart';

/// Extends the functionality of the [String] class with additional methods.
extension LzStringExtension on String {
  /// ``` dart
  /// print('john doe'.ucwords); // John Doe
  /// ```
  String get ucwords {
    try {
      String str = this;
      if (str.trim().isEmpty) return '';

      List<String> split = str.split(' ');
      for (int i = 0; i < split.length; i++) {
        if (split[i] != '') {
          split[i] = split[i][0].toUpperCase() + split[i].substring(1);
        }
      }

      return split.join(' ');
    } catch (e) {
      return '';
    }
  }

  /// ``` dart
  /// print('john doe'.ucfirst); // John doe
  /// ```
  String get ucfirst {
    try {
      String str = this;
      if (str.trim() == '') return '';
      return str[0].toUpperCase() + str.substring(1);
    } catch (e) {
      return '';
    }
  }

  /// ``` dart
  /// print('lipsum99'.getNumeric); // 99
  /// ```
  int get getNumeric {
    try {
      if (trim().isEmpty) return 0;
      String number = replaceAll(RegExp(r'-(?=\D|$)'), '');
      return int.parse(number.replaceAll(RegExp(r'[^0-9-]'), ''));
    } catch (e) {
      return 0;
    }
  }

  /// ``` dart
  /// '<h1>Hello World</h1>'.removeHtmlTag; // Hello World
  /// ```
  String get removeHtmlTag {
    try {
      RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      return replaceAll(exp, '').replaceAll('&nbsp;', '');
    } catch (e) {
      return '!';
    }
  }

  /// ``` dart
  /// '{}'.isJson; // true
  /// ```
  bool get isJson {
    try {
      json.decode(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ``` dart
  /// 'johndoe@doe'.isEmail; // false
  /// 'johndoe@mail.com'.isEmail; // true
  /// ```
  bool get isEmail => RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(this);

  /// ``` dart
  /// 'https://google.com'.isURL; // true
  /// ```
  bool get isURL => RegExp(
          r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$')
      .hasMatch(this);

  /// ``` dart
  /// 'ffffff'.hex; // Color(0xffffffff)
  /// ```

  Color get hex => Utils.hex(this);

  /// ``` dart
  /// 'John Doe'.initials(length = 2); // JD
  /// ```
  String initials({bool firstUppercase = true, int length = 2}) {
    String result = '';

    try {
      List<String> char = trim().split(' ');
      char
          .take(length)
          .forEach((e) => result += firstUppercase ? e[0].ucwords : e[0]);
      return result;
    } catch (e) {
      return '';
    }
  }
}

/// Extension method on [String?] to format the value as a currency string.
extension LzNullableStringExtension on String? {
  /// Formats the value as Indonesian Rupiah (IDR).
  ///
  /// [prefix]: The currency prefix to use. Default is 'Rp'.
  /// [decimalDigits]: The number of decimal digits to display. Default is 0.
  /// [separator]: The separator to use for thousands. Default is '.'.
  ///
  /// Returns the formatted IDR string.
  String idr(
      {String prefix = 'Rp', int decimalDigits = 0, String separator = '.'}) {
    return (this == null ? '0' : toString()).currency(
        prefix: prefix, decimalDigits: decimalDigits, separator: separator);
  }

  /// Format the given value as [currency] using the [NumberFormat] class.
  ///
  /// The [symbol] parameter sets the currency symbol (default: '$').
  /// The [decimalDigits] parameter sets the number of decimal digits to display (default: 0).
  /// The [separator] parameter sets the thousands separator (default: ',').
  ///
  /// Example usage:
  /// ```dart
  /// String price = currency(15000);
  /// print(price); // $15,000
  ///
  /// String priceWithDecimal = currency(25000.50, decimalDigits: 2);
  /// print(priceWithDecimal); // $25,000.50
  /// ```
  String currency(
      {String prefix = '\$', int decimalDigits = 0, String separator = ','}) {
    try {
      String num = '0', digits = '';

      switch (runtimeType.toString()) {
        case 'int':
          num = toString();
          break;

        case 'double':
        case 'String':
          if (toString().contains('.') || toString().contains(',')) {
            // Identify the decimal separator dynamically
            var decimalSeparator = toString().contains('.') ? '.' : ',';
            num = toString().split(decimalSeparator)[0];
            digits = toString().split(decimalSeparator)[1];
          } else {
            num = toString();
          }
          break;

        default:
          return '${prefix}0';
      }

      // Clean only the integer part of non-numeric characters
      num = num.replaceAll(RegExp(r'[^0-9]'), '');

      String result = NumberFormat.currency(
        locale: 'id_ID',
        decimalDigits: 0, // Only format the integer part to avoid rounding
        symbol: prefix,
      ).format(int.parse(num));

      result =
          result.replaceAll('.', separator); // Use the separator for thousands

      // Determine the correct separator for the decimal part
      String decimalSeparator = separator == ',' ? '.' : ',';

      // Append the decimal part manually if it exists
      return digits.isEmpty
          ? result
          : '$result$decimalSeparator${digits.padRight(decimalDigits, '0').substring(0, decimalDigits)}';
    } catch (e) {
      return '${prefix}0';
    }
  }

  /// Support yyyy-MM-dd, dd-MM-yyyy format, with - or / separator
  /// ``` dart
  /// // to convert it to local, the date format must be like this: 2023-07-13T07:05:30.000000Z
  /// // and you have to import 'package:intl/date_symbol_data_local.dart'; in your main.dart
  /// // then call initializeDateFormatting('id_ID', null); in your main() function
  ///
  /// // to convert it to DateTime only, use like this:
  /// "2023-02-10 00:00:00".toDate(); // DateTime(2023, 2, 10, 0, 0, 0)
  /// "10-02-2023 00:00:00".toDate(); // DateTime(2023, 2, 10, 0, 0, 0)
  /// ```
  DateTime toDate({bool toLocal = false}) {
    try {
      String? dateString = this;

      String? getDateStringFormat(String dateString) {
        Map<String, RegExp> formatRegexMap = {
          'y-m-d': RegExp(r'^\d{4}-\d{2}-\d{2}$'),
          'd-m-y': RegExp(r'^\d{2}-\d{2}-\d{4}$'),
          'y.m.d': RegExp(r'^\d{4}\.\d{2}\.\d{2}$'),
          'y/m/d': RegExp(r'^\d{4}/\d{2}/\d{2}$'),
          'd/m/y': RegExp(r'^\d{2}/\d{2}/\d{4}$'),
          'd.m.y': RegExp(r'^\d{2}\.\d{2}\.\d{4}$'),
          'ymd': RegExp(r'^\d{4}\d{2}\d{2}$'),
          'dmy': RegExp(r'^\d{2}\d{2}\d{4}$'),
        };

        String? result;

        for (String format in formatRegexMap.keys) {
          RegExp? r = formatRegexMap[format];

          if (dateString.contains(' ')) {
            dateString =
                dateString.split(' ')[0]; // extract date portion of string
          } else {
            dateString = dateString;
          }

          if (r != null && r.hasMatch(dateString)) {
            result = format;
            break; // exit loop when match is found
          }
        }

        return result;
      }

      if (dateString != null && dateString != '') {
        final fullDate = dateString.split(' ');

        String? format = getDateStringFormat(dateString);
        DateTime result = DateTime.now();

        if (format == 'd/m/y') {
          format = 'd-m-y';
          dateString = dateString.replaceAll('/', '-');
        }

        if (format != null && format == 'd-m-y') {
          RegExp regex = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');
          List<String> dateParts =
              (regex.firstMatch(dateString.split(' ')[0])?.groups([3, 2, 1]) ??
                      [])
                  .cast();
          String ymd = '${dateParts[0]}-${dateParts[1]}-${dateParts[2]}';

          if (fullDate.length > 1) {
            ymd += ' ${fullDate[1]}';
          }

          result = DateTime.parse(ymd);
        } else {
          result = DateTime.parse(dateString);
        }

        return toLocal ? result.toLocal() : result;
      }

      return DateTime.now();
    } catch (e, s) {
      Utils.errorCatcher(e, s);
      return DateTime.now();
    }
  }
}
