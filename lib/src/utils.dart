import 'package:quiver/strings.dart';

String enumFrom(List<String> values) => 'enum[${values.join(',')}]';

Uri parseAddress(String address) {
  Uri parsed;

  String trimTrailingSlashes(String s) {
    if (isEmpty(s)) {
      return '';
    }
    if (s == '/') {
      return '/';
    } else if (s.endsWith('/')) {
      return trimTrailingSlashes(s.substring(0, s.length - 1));
    } else {
      return s;
    }
  }

  String sanitizedAddress = trimTrailingSlashes(address);

  try {
    parsed = Uri.parse(sanitizedAddress);

    if (parsed.scheme.isEmpty) {
      parsed = new Uri.http(parsed.toString(), '');
    }
  } on FormatException {
    parsed = Uri.parse('http://$sanitizedAddress');
  }

  if (isEmpty(parsed.host)) {
    throw new FormatException('Cannot parse provided address $address');
  }

  return parsed;
}
