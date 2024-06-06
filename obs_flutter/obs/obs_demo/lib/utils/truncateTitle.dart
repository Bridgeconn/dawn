String truncateTitle(String title) {
  if (title.length > 20) {
    return title.substring(0, 17) + '...';
  } else {
    return title;
  }
}
