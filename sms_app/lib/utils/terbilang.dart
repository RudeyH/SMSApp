// file: lib/utils/terbilang.dart
String terbilang(int number) {
  if (number < 12) {
    const words = [
      '',
      'satu',
      'dua',
      'tiga',
      'empat',
      'lima',
      'enam',
      'tujuh',
      'delapan',
      'sembilan',
      'sepuluh',
      'sebelas'
    ];
    return words[number];
  } else if (number < 20) {
    return '${terbilang(number - 10)} belas';
  } else if (number < 100) {
    return '${terbilang(number ~/ 10)} puluh ${terbilang(number % 10)}';
  } else if (number < 200) {
    return 'seratus ${terbilang(number - 100)}';
  } else if (number < 1000) {
    return '${terbilang(number ~/ 100)} ratus ${terbilang(number % 100)}';
  } else if (number < 2000) {
    return 'seribu ${terbilang(number - 1000)}';
  } else if (number < 1000000) {
    return '${terbilang(number ~/ 1000)} ribu ${terbilang(number % 1000)}';
  } else if (number < 1000000000) {
    return '${terbilang(number ~/ 1000000)} juta ${terbilang(number % 1000000)}';
  } else if (number < 1000000000000) {
    return '${terbilang(number ~/ 1000000000)} miliar ${terbilang(number % 1000000000)}';
  } else {
    return 'jumlah terlalu besar';
  }
}
