double calcX(Map<String, dynamic> options) {
  switch (options['rotation']) {
    case 90:
      return options['x'] * options['width'] / (options['ios'] ? options['absWidth'] : options['absHeight']);
    case 270:
      return options['width'] -
          options['x'] * options['width'] / (options['ios'] ? options['absWidth'] : options['absHeight']);
    default:
      return options['x'] * options['width'] / options['absWidth'];
  }
}

double calcY(Map<String, dynamic> options) {
  switch (options['rotation']) {
    case 90:
    case 270:
      return options['y'] * options['height'] / (options['ios'] ? options['absHeight'] : options['absWidth']);
    default:
      return options['y'] * options['height'] / options['absHeight'];
  }
}
